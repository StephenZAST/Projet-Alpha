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

export async function getPermission(id: string): Promise<Permission | null> {
  try {
    const { data, error } = await supabase.from(permissionsTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch permission', errorCodes.DATABASE_ERROR);
    }

    return data as Permission;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch permission', errorCodes.DATABASE_ERROR);
  }
}

export async function createPermission(permissionData: Permission): Promise<Permission> {
  try {
    const { data, error } = await supabase.from(permissionsTable).insert([permissionData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create permission', errorCodes.DATABASE_ERROR);
    }

    return data as Permission;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create permission', errorCodes.DATABASE_ERROR);
  }
}

export async function updatePermission(id: string, permissionData: Partial<Permission>): Promise<Permission> {
  try {
    const currentPermission = await getPermission(id);

    if (!currentPermission) {
      throw new AppError(404, 'Permission not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(permissionsTable).update(permissionData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update permission', errorCodes.DATABASE_ERROR);
    }

    return data as Permission;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update permission', errorCodes.DATABASE_ERROR);
  }
}

export async function deletePermission(id: string): Promise<void> {
  try {
    const permission = await getPermission(id);

    if (!permission) {
      throw new AppError(404, 'Permission not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(permissionsTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete permission', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete permission', errorCodes.DATABASE_ERROR);
  }
}
