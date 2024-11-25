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
    adminId: string; // Changed to string for Firebase compatibility
    action: AdminAction;
    targetAdminId?: string; // Changed to string for Firebase compatibility
    details: string;
    ipAddress: string;
    userAgent: string;
    createdAt: Date;
}

const adminLogsRef = db.collection('adminLogs');

// Function to create admin log
export async function createAdminLog(logData: IAdminLog): Promise<IAdminLog> {
    const logRef = await adminLogsRef.add({
        ...logData,
        createdAt: new Date() // Ensure createdAt is a Date object
    });
    return logRef.get().then(doc => doc.data() as IAdminLog);
}

// Function to get admin logs
export async function getAdminLogs(adminId?: string): Promise<IAdminLog[]> {
    let query = adminLogsRef.orderBy('createdAt', 'desc');
    if (adminId) {
        query = query.where('adminId', '==', adminId);
    }
    const snapshot = await query.get();
    return snapshot.docs.map(doc => doc.data() as IAdminLog);
}
