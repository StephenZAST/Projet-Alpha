import { Request } from 'express';
import { AdminLog, AdminAction, IAdminLog } from '../models/adminLog';
import { IAdmin } from '../models/admin';

export class AdminLogService {
    static async logAction(
        adminId: IAdmin['_id'],
        action: AdminAction,
        details: string,
        req: Request,
        targetAdminId?: IAdmin['_id']
    ): Promise<IAdminLog> {
        const log = new AdminLog({
            adminId,
            action,
            details,
            targetAdminId,
            ipAddress: req.ip,
            userAgent: req.get('user-agent') || 'Unknown'
        });

        return await log.save();
    }

    static async getAdminLogs(
        adminId?: string,
        action?: AdminAction,
        startDate?: Date,
        endDate?: Date,
        limit: number = 50,
        skip: number = 0
    ): Promise<IAdminLog[]> {
        const query: any = {};

        if (adminId) query.adminId = adminId;
        if (action) query.action = action;
        if (startDate || endDate) {
            query.createdAt = {};
            if (startDate) query.createdAt.$gte = startDate;
            if (endDate) query.createdAt.$lte = endDate;
        }

        return await AdminLog.find(query)
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit)
            .populate('adminId', 'email firstName lastName role')
            .populate('targetAdminId', 'email firstName lastName role');
    }

    static async getLogCount(
        adminId?: string,
        action?: AdminAction,
        startDate?: Date,
        endDate?: Date
    ): Promise<number> {
        const query: any = {};

        if (adminId) query.adminId = adminId;
        if (action) query.action = action;
        if (startDate || endDate) {
            query.createdAt = {};
            if (startDate) query.createdAt.$gte = startDate;
            if (endDate) query.createdAt.$lte = endDate;
        }

        return await AdminLog.countDocuments(query);
    }

    static async getRecentActivityByAdmin(adminId: string, limit: number = 10): Promise<IAdminLog[]> {
        return await AdminLog.find({ adminId })
            .sort({ createdAt: -1 })
            .limit(limit)
            .populate('targetAdminId', 'email firstName lastName role');
    }

    static async getFailedLoginAttempts(
        adminId: string,
        timeWindow: number = 15 // minutes
    ): Promise<number> {
        const windowStart = new Date(Date.now() - timeWindow * 60 * 1000);
        
        return await AdminLog.countDocuments({
            adminId,
            action: AdminAction.FAILED_LOGIN,
            createdAt: { $gte: windowStart }
        });
    }
}
