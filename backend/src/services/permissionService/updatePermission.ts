import supabase from '../../config/supabase';
import { Permission } from '../../models/permission';
import { AppError, errorCodes } from '../../utils/errors';

export const updatePermission = async (id: string, name: string, description: string, roles: string[]): Promise<Permission | null> => {
  if (!id || !name || !description || !roles) {
    throw new AppError(400, 'All fields are required', 'INVALID_PERMISSION_DATA');
  }

  try {
    const { data, error } = await supabase.from('permissions').update({
      name,
      description,
      roles: roles.join(','),
      updated_at: new Date().toISOString()
    }).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update permission', 'INTERNAL_SERVER_ERROR');
    }

    if (data && typeof data.roles === 'string') {
      data.roles = data.roles.split(',').map((role: string) => role.trim());
    }

    return data as Permission;
  } catch (error) {
    throw new AppError(500, 'Failed to update permission', 'INTERNAL_SERVER_ERROR');
  }
};
