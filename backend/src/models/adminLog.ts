import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export interface AdminLog {
  id?: string;
  adminId: string;
  action: string;
  details: string;
  createdAt?: string;
  updatedAt?: string;
}

// Use Supabase to store admin log data
const adminLogsTable = 'adminLogs';

// Function to get admin log data
export async function getAdminLog(id: string): Promise<AdminLog | null> {
  const { data, error } = await supabase.from(adminLogsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch admin log', 'INTERNAL_SERVER_ERROR');
  }

  return data as AdminLog;
}

// Function to create admin log
export async function createAdminLog(adminLogData: AdminLog): Promise<AdminLog> {
  const { data, error } = await supabase.from(adminLogsTable).insert([adminLogData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create admin log', 'INTERNAL_SERVER_ERROR');
  }

  return data as AdminLog;
}

// Function to update admin log
export async function updateAdminLog(id: string, adminLogData: Partial<AdminLog>): Promise<AdminLog> {
  const currentAdminLog = await getAdminLog(id);

  if (!currentAdminLog) {
    throw new AppError(404, 'Admin log not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(adminLogsTable).update(adminLogData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update admin log', 'INTERNAL_SERVER_ERROR');
  }

  return data as AdminLog;
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
