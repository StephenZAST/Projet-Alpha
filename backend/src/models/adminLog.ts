import { db } from '../config/firebase';
import { IAdmin } from './admin';

export enum AdminAction {
  LOGIN = 'LOGIN',
  LOGOUT = 'LOGOUT',
  CREATE_ADMIN = 'CREATE_ADMIN',
  UPDATE_ADMIN = 'UPDATE_ADMIN',
  DELETE_ADMIN = 'DELETE_ADMIN',
  TOGGLE_STATUS = 'TOGGLE_STATUS',
  FAILED_LOGIN = 'FAILED_LOGIN'
}

export interface IAdminLog {
  adminId: string;
  action: AdminAction;
  targetAdminId?: string;
  details: string;
  ipAddress: string;
  userAgent: string;
  createdAt: Date;
}

// Export adminLogsRef
export const adminLogsRef = db.collection('adminLogs');

export const AdminLog = {
  createAdminLog: async (logData: IAdminLog): Promise<IAdminLog> => {
    const logRef = await adminLogsRef.add({
      ...logData,
      createdAt: new Date(),
    });
    const log = await logRef.get();
    return log.data() as IAdminLog;
  },
  getAdminLogs: async (adminId?: string): Promise<IAdminLog[]> => {
    let query = adminLogsRef.orderBy('createdAt', 'desc');
    if (adminId) {
      query = query.where('adminId', '==', adminId);
    }
    const snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data() as IAdminLog);
  },
};
