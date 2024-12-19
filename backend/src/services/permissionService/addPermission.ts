import { supabase } from '../../config/supabase';
import { Permission } from '../../models/permission';
import { AppError, errorCodes } from '../../utils/errors';

export const addPermission = async (permission: Permission): Promise<Permission> => {
  try {
    const { data, error } = await supabase.from('permissions').insert([
      {
        name: permission.name,
        description: permission.description,
        roles: permission.roles.join(','),
        created_at: new Date().toISOString()
      }
    ]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to add permission', 'INTERNAL_SERVER_ERROR');
    }

    if (!data) {
      throw new AppError(500, 'Failed to add permission', 'INTERNAL_SERVER_ERROR');
    }

    return data as Permission;
  } catch (error) {
    throw new AppError(500, 'Failed to add permission', 'INTERNAL_SERVER_ERROR');
  }
};
