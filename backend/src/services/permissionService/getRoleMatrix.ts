import supabase from '../../config/supabase';
import { Permission } from '../../models/permission';
import { AppError, errorCodes } from '../../utils/errors';

export const getRoleMatrix = async (): Promise<Record<string, string[]>> => {
  try {
    const { data, error } = await supabase.from('permissions').select('*');

    if (error) {
      throw new AppError(500, 'Failed to fetch role matrix', 'INTERNAL_SERVER_ERROR');
    }

    if (!data) {
      throw new AppError(500, 'Failed to fetch role matrix', 'INTERNAL_SERVER_ERROR');
    }

    const roleMatrix: Record<string, string[]> = {};

    data.forEach((permission: Permission) => {
      if (typeof permission.roles === 'string') {
        (permission.roles as string).split(',').forEach((role: string) => {
          role = role.trim();
          if (!roleMatrix[role]) {
            roleMatrix[role] = [];
          }
          roleMatrix[role].push(permission.name);
        });
      }
    });

    return roleMatrix;
  } catch (error) {
    throw new AppError(500, 'Failed to fetch role matrix', 'INTERNAL_SERVER_ERROR');
  }
};
