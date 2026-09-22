import { Prisma } from '@prisma/client';
import { Request } from 'express';
import prisma from '../config/prisma';

export interface AdminActivityInput {
  action: string;
  details?: Record<string, unknown>;
}

export class AdminActivityService {
  static async log(req: Request, input: AdminActivityInput): Promise<void> {
    const userId = req.user?.id;

    if (!userId) {
      return;
    }

    try {
      await prisma.user_activity_logs.create({
        data: {
          userId,
          action: input.action,
          details: (input.details ?? {}) as Prisma.InputJsonValue,
          ip_address: req.ip,
          user_agent: req.get('user-agent')?.substring(0, 500),
        },
      });
    } catch (error) {
      // An audit failure must not turn a successful business operation into a 500.
      console.error('[AdminActivityService] Failed to record activity:', error);
    }
  }

  static async list(options: {
    userId?: string;
    action?: string;
    startDate?: Date;
    endDate?: Date;
    page?: number;
    limit?: number;
  }) {
    const page = Math.max(options.page ?? 1, 1);
    const limit = Math.min(Math.max(options.limit ?? 50, 1), 100);
    const where = {
      ...(options.userId ? { userId: options.userId } : {}),
      ...(options.action ? { action: options.action } : {}),
      ...(options.startDate || options.endDate
        ? {
            created_at: {
              ...(options.startDate ? { gte: options.startDate } : {}),
              ...(options.endDate ? { lte: options.endDate } : {}),
            },
          }
        : {}),
    };

    const [logs, total] = await Promise.all([
      prisma.user_activity_logs.findMany({
        where,
        include: {
          users: {
            select: { first_name: true, last_name: true, role: true },
          },
        },
        orderBy: { created_at: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.user_activity_logs.count({ where }),
    ]);

    return {
      logs: logs.map((log) => {
        const details = (log.details ?? {}) as Record<string, unknown>;
        const adminName = [log.users.first_name, log.users.last_name]
          .filter(Boolean)
          .join(' ');

        return {
          id: log.id,
          adminId: log.userId,
          adminName: adminName || log.userId,
          adminRole: log.users.role,
          action: log.action,
          entityType: details.entityType ?? details.targetType ?? 'SYSTEM',
          entityId: details.entityId ?? details.targetId ?? '',
          details,
          ipAddress: log.ip_address,
          userAgent: log.user_agent,
          createdAt: log.created_at,
        };
      }),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}
