import supabase from '../../config/supabase';
import { Permission } from '../../models/permission';
import { AppError, errorCodes } from '../../utils/errors';

export const getPermissions = async (): Promise<Permission[]> => {
  try {
    const { data, error } = await supabase.from('permissions').select('*');

    if (error) {
      throw new AppError(500, 'Failed to fetch permissions', 'INTERNAL_SERVER_ERROR');
    }

    if (!data) {
      throw new AppError(500, 'Failed to fetch permissions', 'INTERNAL_SERVER_ERROR');
    }

    return data.map((permission: Permission) => {
      if (typeof permission.roles === 'string') {
        return {
          ...permission,
          roles: (permission.roles as string).split(',').map((role: string) => role.trim())
        };
      } else {
        return permission;
      }
    }) as Permission[];
  } catch (error) {
    throw new AppError(500, 'Failed to fetch permissions', 'INTERNAL_SERVER_ERROR');
  }
};
