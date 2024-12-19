import { supabase } from '../../config/supabase';
import { User, UserStatus } from '../../models/user';
import { AppError, errorCodes } from '../../utils/errors';

const usersTable = 'users';

export async function deleteUser(id: string): Promise<void> {
  try {
    const { error: userError } = await supabase.from(usersTable).select('id').eq('id', id).single();

    if (userError) {
      throw new AppError(404, 'User not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(usersTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete user', 'INTERNAL_SERVER_ERROR');
    }
  } catch (error) {
    console.error('Error deleting user:', error);
    throw error;
  }
}
