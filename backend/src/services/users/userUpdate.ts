import supabase from '../../config/supabase';
import { User, UserProfile, UserAddress, UserPreferences } from '../../models/user';
import { AppError, errorCodes } from '../../utils/errors';
import { NotificationService, NotificationType } from '../notifications';
import { Timestamp } from 'firebase-admin/firestore';

const usersTable = 'users';

export async function updateProfile(userId: string, updateData: Partial<UserProfile>): Promise<UserProfile> {
  try {
    const { data: user, error: userError } = await supabase.from(usersTable).select('profile').eq('id', userId).single();

    if (userError) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    if (!user) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    const existingProfile = user.profile || {};
    const updatedProfile = {
      ...existingProfile,
      ...updateData,
    };

    const { error } = await supabase.from(usersTable).update({ profile: updatedProfile }).eq('id', userId);

    if (error) {
      throw new AppError(500, 'Failed to update profile', 'INTERNAL_SERVER_ERROR');
    }

    // Notify user about profile update
    const notificationService = new NotificationService();
    await notificationService.sendNotification(userId, {
      type: NotificationType.PROFILE_UPDATE,
      title: 'Profile Updated',
      message: 'Your profile has been successfully updated',
      data: {}
    });

    return updatedProfile;
  } catch (error) {
    if (error instanceof AppError) throw error;
    throw new AppError(500, 'Failed to update profile', 'INTERNAL_SERVER_ERROR');
  }
}

export async function updateAddress(userId: string, address: UserAddress): Promise<UserAddress> {
  try {
    const { data: user, error: userError } = await supabase.from(usersTable).select('address').eq('id', userId).single();

    if (userError) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    if (!user) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    const { error } = await supabase.from(usersTable).update({ address, updatedAt: Timestamp.now() }).eq('id', userId);

    if (error) {
      throw new AppError(500, 'Failed to update address', 'INTERNAL_SERVER_ERROR');
    }

    return address;
  } catch (error) {
    if (error instanceof AppError) throw error;
    throw new AppError(500, 'Failed to update address', 'INTERNAL_SERVER_ERROR');
  }
}

export async function updatePreferences(userId: string, preferences: Partial<UserPreferences>): Promise<UserPreferences> {
  try {
    const { data: user, error: userError } = await supabase.from(usersTable).select('profile').eq('id', userId).single();

    if (userError) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    if (!user || !user.profile) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    const existingPreferences = user.profile.preferences || { notifications: { email: false, sms: false, push: false }, language: 'en' };
    const updatedPreferences = {
      ...existingPreferences,
      ...preferences
    };

    const { error } = await supabase.from(usersTable).update({ profile: { ...user.profile, preferences: updatedPreferences }, updatedAt: Timestamp.now() }).eq('id', userId);

    if (error) {
      throw new AppError(500, 'Failed to update preferences', 'INTERNAL_SERVER_ERROR');
    }

    return updatedPreferences;
  } catch (error) {
    if (error instanceof AppError) throw error;
    throw new AppError(500, 'Failed to update preferences', 'INTERNAL_SERVER_ERROR');
  }
}

export async function updateUser(id: string, userData: Partial<User>): Promise<User> {
  try {
    const { data: existingUser, error: userError } = await supabase.from(usersTable).select('*').eq('id', id).single();

    if (userError) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    if (!existingUser) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    const updatedUser = {
      ...existingUser,
      ...userData,
      updatedAt: Timestamp.now(),
    };

    const { data, error } = await supabase.from(usersTable).update(updatedUser).eq('id', id).select('*').single();

    if (error) {
      throw new AppError(500, 'Failed to update user', 'INTERNAL_SERVER_ERROR');
    }

    if (!data) {
      throw new AppError(500, 'Failed to update user', 'INTERNAL_SERVER_ERROR');
    }

    return data as User;
  } catch (error) {
    console.error('Error updating user:', error);
    throw error;
  }
}
