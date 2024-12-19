import { createClient } from '@supabase/supabase-js';
import { Permission } from '../../models/permission';
import { AppError, errorCodes } from '../../utils/errors';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

const permissionsTable = 'permissions';

export async function getPermissions(): Promise<Permission[]> {
  const { data, error } = await supabase.from(permissionsTable).select('*');

  if (error) {
    throw new AppError(500, 'Failed to fetch permissions', errorCodes.DATABASE_ERROR);
  }

  return data as Permission[];
}

export async function getPermissionById(id: string): Promise<Permission | null> {
  const { data, error } = await supabase.from(permissionsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch permission', errorCodes.DATABASE_ERROR);
  }

  return data as Permission | null;
}

export async function updatePermission(id: string, permissionData: Partial<Permission>): Promise<Permission> {
  const { data, error } = await supabase.from(permissionsTable).update(permissionData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update permission', errorCodes.DATABASE_ERROR);
  }

  return data as Permission;
}

export async function deletePermissionById(id: string): Promise<void> {
    const { error } = await supabase.from(permissionsTable).delete().eq('id', id);
  
    if (error) {
      throw new AppError(500, 'Failed to delete permission', errorCodes.DATABASE_ERROR);
    }
  }

export async function initializeDefaultPermissions(permissions: Permission[]): Promise<void> {
  const { error } = await supabase.from(permissionsTable).insert(permissions);

  if (error) {
    throw new AppError(500, 'Failed to initialize default permissions', errorCodes.DATABASE_ERROR);
  }
}

export async function getPermissionsByRole(role: string): Promise<Permission[]> {
  const { data, error } = await supabase.from(permissionsTable).select('*').contains('roles', [role]);

  if (error) {
    throw new AppError(500, 'Failed to fetch permissions by role', errorCodes.DATABASE_ERROR);
  }

  return data as Permission[];
}

export async function removePermissionById(id: string): Promise<void> {
    const { error } = await supabase.from(permissionsTable).delete().eq('id', id);
  
    if (error) {
      throw new AppError(500, 'Failed to remove permission', errorCodes.DATABASE_ERROR);
    }
  }

export async function getRoleMatrix(): Promise<any> {
    const { data: permissions, error: permissionsError } = await supabase.from(permissionsTable).select('*');
  
    if (permissionsError) {
      throw new AppError(500, 'Failed to fetch permissions for role matrix', errorCodes.DATABASE_ERROR);
    }
  
    const roles = Array.from(new Set(permissions?.flatMap(p => p.roles)));
    const roleMatrix: any = {};
  
    roles.forEach(role => {
      roleMatrix[role] = permissions?.filter(p => p.roles.includes(role)).map(p => p.name);
    });
  
    return roleMatrix;
  }

export async function getResourcePermissions(resource: string): Promise<Permission[]> {
  const { data, error } = await supabase.from(permissionsTable).select('*').ilike('name', `%${resource}%`);

  if (error) {
    throw new AppError(500, 'Failed to fetch resource permissions', errorCodes.DATABASE_ERROR);
  }

  return data as Permission[];
}

export async function createPermissionUtil(permissionData: Permission): Promise<Permission> {
    const { data, error } = await supabase.from(permissionsTable).insert([permissionData]).select().single();
  
    if (error) {
      throw new AppError(500, 'Failed to create permission', errorCodes.DATABASE_ERROR);
    }
  
    return data as Permission;
  }
