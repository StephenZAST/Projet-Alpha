import supabase from '../../config/supabase';
import { User, UserStatus } from '../../models/user';
import { AppError, errorCodes } from '../../utils/errors';

const usersTable = 'users';

export async function deleteUser(id: string): Promise<void> {
  try {
    const userRef = supabase.from(usersTable).eq('id', id);
    const { data: user, error: userError } = await userRef.select('*').single();

    if (userError) {
      throw new AppError(404, 'User not found', errorCodes.NOT_FOUND);
    }

    const { error } = await userRef.update({ status: UserStatus.DELETED, updatedAt: new Date().toISOString() });

    if (error) {
      throw new AppError(500, 'Failed to delete user', 'INTERNAL_SERVER_ERROR');
    }
  } catch (error) {
    console.error('Error deleting user:', error);
    throw error;
  }
}
