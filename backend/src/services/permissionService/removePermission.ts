import { supabase } from '../../config/supabase';
import { Permission } from '../../models/permission';
import { AppError, errorCodes } from '../../utils/errors';

export const removePermission = async (id: string): Promise<Permission | null> => {
  if (!id) {
    throw new AppError(400, 'ID is required', 'INVALID_ID');
  }

  try {
    const { data, error } = await supabase.from('permissions').delete().eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to remove permission', 'INTERNAL_SERVER_ERROR');
    }

    if (data && typeof data.roles === 'string') {
      data.roles = data.roles.split(',').map((role: string) => role.trim());
    }

    return data as Permission;
  } catch (error) {
    throw new AppError(500, 'Failed to remove permission', 'INTERNAL_SERVER_ERROR');
  }
};
