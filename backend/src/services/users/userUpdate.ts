import supabase from '../../config/supabase';
import { User, UserProfile, UserAddress, UserPreferences } from '../../models/user';
import { AppError, errorCodes } from '../../utils/errors';
import { NotificationService, NotificationType } from '../notifications';

const usersTable = 'users';

export async function updateProfile(userId: string, updateData: Partial<UserProfile>): Promise<UserProfile> {
  try {
    const userRef = supabase.from(usersTable).eq('id', userId);
    const { data: user, error: userError } = await userRef.select('*').single();

    if (userError) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    const updatedData = {
      ...updateData,
      lastUpdated: new Date().toISOString()
    };

    const { data, error } = await userRef.update({ profile: updatedData });

    if (error) {
      throw new AppError(500, 'Failed to update profile', 'INTERNAL_SERVER_ERROR');
    }

    // Notify user about profile update
    const notificationService = new NotificationService();
    await notificationService.sendNotification(userId, {
      type: NotificationType.PROFILE_UPDATE,
      title: 'Profile Updated',
      message: 'Your profile has been successfully updated',
      data: {
        orderId: undefined,
        recurringOrderId: ''
      }
    });

    return {
      ...user.profile,
      ...updatedData
    };
  } catch (error) {
    if (error instanceof AppError) throw error;
    throw new AppError(500, 'Failed to update profile', 'INTERNAL_SERVER_ERROR');
  }
}

export async function updateAddress(userId: string, address: UserAddress): Promise<UserAddress> {
  try {
    const userRef = supabase.from(usersTable).eq('id', userId);
    const { data: user, error: userError } = await userRef.select('*').single();

    if (userError) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    const { data, error } = await userRef.update({ address, updatedAt: new Date().toISOString() });

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
    const userRef = supabase.from(usersTable).eq('id', userId);
    const { data: user, error: userError } = await userRef.select('*').single();

    if (userError) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    const updatedPreferences = {
      ...user.profile.preferences,
      ...preferences
    };

    const { data, error } = await userRef.update({ 'profile.preferences': updatedPreferences, updatedAt: new Date().toISOString() });

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
    const userRef = supabase.from(usersTable).eq('id', id);
    const { data: user, error: userError } = await userRef.select('*').single();

    if (userError) {
      throw new AppError(404, 'User not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await userRef.update(userData);

    if (error) {
      throw new AppError(500, 'Failed to update user', 'INTERNAL_SERVER_ERROR');
    }

    return data as User;
  } catch (error) {
    console.error('Error updating user:', error);
    throw error;
  }
}
