import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export interface Permission {
  id?: string;
  name: string;
  description: string;
  roles: string[];
  created_at?: string;
  updated_at?: string;
}

// Use Supabase to store permission data
const permissionsTable = 'permissions';

// Function to get permission data
export async function getPermission(id: string): Promise<Permission | null> {
  const { data, error } = await supabase.from(permissionsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch permission', 'INTERNAL_SERVER_ERROR');
  }

  return data as Permission;
}

// Function to create permission
export async function createPermission(permissionData: Permission): Promise<Permission> {
  const { data, error } = await supabase.from(permissionsTable).insert([permissionData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create permission', 'INTERNAL_SERVER_ERROR');
  }

  return data as Permission;
}

// Function to update permission
export async function updatePermission(id: string, permissionData: Partial<Permission>): Promise<Permission> {
  const currentPermission = await getPermission(id);

  if (!currentPermission) {
    throw new AppError(404, 'Permission not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(permissionsTable).update(permissionData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update permission', 'INTERNAL_SERVER_ERROR');
  }

  return data as Permission;
}

// Function to delete permission
export async function deletePermission(id: string): Promise<void> {
  const permission = await getPermission(id);

  if (!permission) {
    throw new AppError(404, 'Permission not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(permissionsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete permission', 'INTERNAL_SERVER_ERROR');
  }
}
