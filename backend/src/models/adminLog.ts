import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';
import { AdminRole } from './admin';

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
  id?: string;
  adminId: string;
  action: AdminAction;
  targetAdminId?: string;
  details: string;
  ipAddress: string;
  userAgent: string;
  createdAt: string;
}

// Use Supabase to store admin log data
const adminLogsTable = 'adminLogs';

// Function to get admin log data
export async function getAdminLog(id: string): Promise<IAdminLog | null> {
  const { data, error } = await supabase.from(adminLogsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch admin log', 'INTERNAL_SERVER_ERROR');
  }

  return data as IAdminLog;
}

// Function to create admin log
export async function createAdminLog(logData: IAdminLog): Promise<IAdminLog> {
  const { data, error } = await supabase.from(adminLogsTable).insert([{
    ...logData,
    createdAt: new Date().toISOString(),
  }]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create admin log', 'INTERNAL_SERVER_ERROR');
  }

  return data as IAdminLog;
}

// Function to get admin logs
export async function getAdminLogs(adminId?: string): Promise<IAdminLog[]> {
  let query = supabase.from(adminLogsTable).select('*').order('createdAt', { ascending: false });

  if (adminId) {
    query = query.eq('adminId', adminId);
  }

  const { data, error } = await query;

  if (error) {
    throw new AppError(500, 'Failed to fetch admin logs', 'INTERNAL_SERVER_ERROR');
  }

  return data as IAdminLog[];
}

// Function to delete admin log
export async function deleteAdminLog(id: string): Promise<void> {
  const adminLog = await getAdminLog(id);

  if (!adminLog) {
    throw new AppError(404, 'Admin log not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(adminLogsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete admin log', 'INTERNAL_SERVER_ERROR');
  }
}
