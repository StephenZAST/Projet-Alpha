import { Request } from 'express';
import { AdminAction, IAdminLog, adminLogsRef } from '../models/adminLog';
import { IAdmin } from '../models/admin';
import { Query } from '@google-cloud/firestore';

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
      userAgent: req.get('user-agent') || 'Unknown',
      createdAt: new Date(),
    };

    const logRef = await adminLogsRef.add(newLog);
    await logRef.set(newLog);
    return newLog;
  }

  static async getAdminLogs(
    adminId?: string,
    action?: AdminAction,
    startDate?: Date,
    endDate?: Date,
    limit: number = 50,
    skip: number = 0
  ): Promise<IAdminLog[]> {
    let query: Query = adminLogsRef.orderBy('createdAt', 'desc');

    if (adminId) {
      query = query.where('adminId', '==', adminId);
    }
    if (action) {
      query = query.where('action', '==', action);
    }
    if (startDate) {
      query = query.where('createdAt', '>=', startDate);
    }
    if (endDate) {
      query = query.where('createdAt', '<=', endDate);
    }

    const snapshot = await query.limit(limit).offset(skip).get();
    return snapshot.docs.map((doc: FirebaseFirestore.QueryDocumentSnapshot) => doc.data() as IAdminLog);
  }

  static async getLogCount(
    adminId?: string,
    action?: AdminAction,
    startDate?: Date,
    endDate?: Date
  ): Promise<number> {
    let query: Query = adminLogsRef;

    if (adminId) {
      query = query.where('adminId', '==', adminId);
    }
    if (action) {
      query = query.where('action', '==', action);
    }
    if (startDate) {
      query = query.where('createdAt', '>=', startDate);
    }
    if (endDate) {
      query = query.where('createdAt', '<=', endDate);
    }

    const snapshot = await query.get();
    return snapshot.size;
  }

  static async getRecentActivityByAdmin(adminId: string, limit: number = 10): Promise<IAdminLog[]> {
    const snapshot = await adminLogsRef
      .where('adminId', '==', adminId)
      .orderBy('createdAt', 'desc')
      .limit(limit)
      .get();

    return snapshot.docs.map((doc: FirebaseFirestore.QueryDocumentSnapshot) => {
      const log = doc.data() as IAdminLog;
      return log;
    });
  }

  static async getFailedLoginAttempts(adminId: string, timeWindow: number = 15): Promise<number> {
    const windowStart = new Date(Date.now() - timeWindow * 60 * 1000);

    const snapshot = await adminLogsRef
      .where('adminId', '==', adminId)
      .where('action', '==', AdminAction.FAILED_LOGIN)
      .where('createdAt', '>=', windowStart)
      .get();

    return snapshot.size;
  }
}
