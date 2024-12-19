import { AppError, errorCodes } from '../../utils/errors';
import { User, UpdateUserInput, UserAddress, UserPreferences, UserProfile } from '../../models/user';
import  supabase  from '../../config/supabase';

const usersTable = 'users';

export async function updateUser(id: string, updateData: UpdateUserInput): Promise<User> {
  try {
    const { data, error } = await supabase
      .from(usersTable)
      .update(updateData)
      .eq('id', id)
      .select()
      .single();

    if (error) {
      throw new AppError(500, 'Failed to update user', errorCodes.DATABASE_ERROR);
    }

    if (!data) {
      throw new AppError(404, 'User not found', errorCodes.NOT_FOUND);
    }

    return data as User;
  } catch (error) {
    console.error('Error updating user:', error);
    throw error;
  }
}

export async function updateProfile(userId: string, updateData: Partial<UserProfile>): Promise<UserProfile> {
  try {
    const { data: user, error: userError } = await supabase
      .from(usersTable)
      .select('profile')
      .eq('id', userId)
      .single();

    if (userError) {
      throw new AppError(500, 'Failed to fetch user profile', errorCodes.DATABASE_ERROR);
    }

    if (!user) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    const updatedProfile = {
      ...user.profile,
      ...updateData,
    };

    const { data, error } = await supabase
      .from(usersTable)
      .update({ profile: updatedProfile })
      .eq('id', userId)
      .select()
      .single();

    if (error) {
      throw new AppError(500, 'Failed to update profile', errorCodes.DATABASE_ERROR);
    }

    if (!data) {
      throw new AppError(500, 'Failed to update profile', errorCodes.DATABASE_ERROR);
    }

    return data.profile as UserProfile;
  } catch (error) {
    if (error instanceof AppError) {
      throw error;
    }
    throw new AppError(500, 'Failed to update profile', errorCodes.DATABASE_ERROR);
  }
}

export async function updateAddress(userId: string, address: UserAddress): Promise<UserAddress> {
  try {
    const { data, error } = await supabase
      .from(usersTable)
      .update({ address })
      .eq('id', userId)
      .select()
      .single();

    if (error) {
      throw new AppError(500, 'Failed to update address', errorCodes.DATABASE_ERROR);
    }

    if (!data) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    return data.address as UserAddress;
  } catch (error) {
    if (error instanceof AppError) {
      throw error;
    }
    throw new AppError(500, 'Failed to update address', errorCodes.DATABASE_ERROR);
  }
}

export async function updatePreferences(userId: string, preferences: Partial<UserPreferences>): Promise<UserPreferences> {
  try {
    const { data: user, error: userError } = await supabase
      .from(usersTable)
      .select('profile')
      .eq('id', userId)
      .single();

    if (userError) {
      throw new AppError(500, 'Failed to fetch user preferences', errorCodes.DATABASE_ERROR);
    }

    if (!user || !user.profile) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    const updatedPreferences = {
      ...user.profile.preferences,
      ...preferences,
    };

    const { data, error } = await supabase
      .from(usersTable)
      .update({ profile: { ...user.profile, preferences: updatedPreferences } })
      .eq('id', userId)
      .select()
      .single();

    if (error) {
      throw new AppError(500, 'Failed to update preferences', errorCodes.DATABASE_ERROR);
    }

    if (!data) {
      throw new AppError(500, 'Failed to update preferences', errorCodes.DATABASE_ERROR);
    }

    return data.profile.preferences as UserPreferences;
  } catch (error) {
    if (error instanceof AppError) {
      throw error;
    }
    throw new AppError(500, 'Failed to update preferences', errorCodes.DATABASE_ERROR);
  }
}
