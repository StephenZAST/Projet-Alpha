import supabase from '../config/supabase';
import { AdminAction, IAdminLog } from '../models/adminLog';
import { IAdmin } from '../models/admin';
import { AppError, errorCodes } from '../utils/errors';
import { Request } from 'express';

const adminLogsTable = 'adminLogs';

export class AdminLogService {
  static async logAction(
    adminId: string,
    action: AdminAction,
    details: string,
    req: Request,
    targetAdminId: string = ''
  ): Promise<IAdminLog> {
    const newLog: IAdminLog = {
      adminId,
      action,
      details,
      targetAdminId: targetAdminId || '',
      ipAddress: req.ip || '', // Provide default empty string for ipAddress
      userAgent: req.headers['user-agent'] || 'Unknown',
      createdAt: new Date().toISOString(),
    };

    const { data, error } = await supabase.from(adminLogsTable).insert([newLog]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to log admin action', 'INTERNAL_SERVER_ERROR');
    }

    return data as IAdminLog;
  }

  static async getAdminLog(id: string): Promise<IAdminLog | null> {
    const { data, error } = await supabase.from(adminLogsTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch admin log', 'INTERNAL_SERVER_ERROR');
    }

    return data as IAdminLog;
  }

  static async getAdminLogs(
    adminId?: string,
    action?: AdminAction,
    startDate?: Date,
    endDate?: Date,
    limit: number = 50,
    skip: number = 0
  ): Promise<IAdminLog[]> {
    let query = supabase.from(adminLogsTable).select('*').order('createdAt', { ascending: false });

    if (adminId) {
      query = query.eq('adminId', adminId);
    }
    if (action) {
      query = query.eq('action', action);
    }
    if (startDate) {
      query = query.gte('createdAt', startDate.toISOString());
    }
    if (endDate) {
      query = query.lte('createdAt', endDate.toISOString());
    }

    const { data, error } = await query.range(skip, skip + limit - 1);

    if (error) {
      throw new AppError(500, 'Failed to fetch admin logs', 'INTERNAL_SERVER_ERROR');
    }

    return data as IAdminLog[];
  }

  static async getLogCount(
    adminId?: string,
    action?: AdminAction,
    startDate?: Date,
    endDate?: Date
  ): Promise<number> {
    let query = supabase.from(adminLogsTable).select('*', { count: 'exact' });

    if (adminId) {
      query = query.eq('adminId', adminId);
    }
    if (action) {
      query = query.eq('action', action);
    }
    if (startDate) {
      query = query.gte('createdAt', startDate.toISOString());
    }
    if (endDate) {
      query = query.lte('createdAt', endDate.toISOString());
    }

    const { count, error } = await query;

    if (error) {
      throw new AppError(500, 'Failed to fetch log count', 'INTERNAL_SERVER_ERROR');
    }

    return count || 0;
  }

  static async getRecentActivityByAdmin(adminId: string, limit: number = 10): Promise<IAdminLog[]> {
    const { data, error } = await supabase
      .from(adminLogsTable)
      .select('*')
      .eq('adminId', adminId)
      .order('createdAt', { ascending: false })
      .limit(limit);

    if (error) {
      throw new AppError(500, 'Failed to fetch recent activity', 'INTERNAL_SERVER_ERROR');
    }

    return data as IAdminLog[];
  }

  static async getFailedLoginAttempts(adminId: string, timeWindow: number = 15): Promise<number> {
    const windowStart = new Date(Date.now() - timeWindow * 60 * 1000);

    const { data, error } = await supabase
      .from(adminLogsTable)
      .select('*')
      .eq('adminId', adminId)
      .eq('action', AdminAction.FAILED_LOGIN)
      .gte('createdAt', windowStart.toISOString());

    if (error) {
      throw new AppError(500, 'Failed to fetch failed login attempts', 'INTERNAL_SERVER_ERROR');
    }

    return data ? data.length : 0;
  }

  static async deleteAdminLog(id: string): Promise<void> {
    const adminLog = await this.getAdminLog(id);

    if (!adminLog) {
      throw new AppError(404, 'Admin log not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(adminLogsTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete admin log', 'INTERNAL_SERVER_ERROR');
    }
  }
}
