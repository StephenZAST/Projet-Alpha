import supabase from '../../config/supabase';
import { Permission } from '../../models/permission';
import { AppError, errorCodes } from '../../utils/errors';

export const createPermission = async (name: string, description: string, roles: string[]): Promise<Permission> => {
  if (!name || !description || !roles) {
    throw new AppError(400, 'All fields are required', 'INVALID_PERMISSION_DATA');
  }

  try {
    const { data, error } = await supabase.from('permissions').insert([
      {
        name,
        description,
        roles: roles.join(','),
        created_at: new Date().toISOString()
      }
    ]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create permission', 'INTERNAL_SERVER_ERROR');
    }

    if (!data) {
      throw new AppError(500, 'Failed to create permission', 'INTERNAL_SERVER_ERROR');
    }

    return data as Permission;
  } catch (error) {
    throw new AppError(500, 'Failed to create permission', 'INTERNAL_SERVER_ERROR');
  }
};
