import { db } from '../../config/firebase';
import { User, UserProfile, UserAddress, UserPreferences } from '../../models/user';
import { AppError, errorCodes } from '../../utils/errors';
import { NotificationService } from '../notifications';
import { Timestamp } from 'firebase/firestore';

const USERS_COLLECTION = 'users';

export class UserUpdateService {
  private usersRef = db.collection(USERS_COLLECTION);
  private notificationService = new NotificationService();

  async updateProfile(userId: string, updateData: Partial<UserProfile>): Promise<UserProfile> {
    try {
      const userRef = this.usersRef.doc(userId);
      const userDoc = await userRef.get();

      if (!userDoc.exists) {
        throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
      }

      const updatedData: Partial<UserProfile> = {
        ...updateData,
        lastUpdated: Timestamp.now()
      };

      await userRef.update({
        profile: updatedData
      });

      // Notify user about profile update
      await this.notificationService.sendNotification(userId, {
        type: 'PROFILE_UPDATE',
        title: 'Profile Updated',
        message: 'Your profile has been successfully updated',
        data: {
          orderId: undefined,
          recurringOrderId: ''
        }
      });

      return {
        ...(userDoc.data() as User).profile,
        ...updatedData
      } as UserProfile;
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to update profile', errorCodes.DATABASE_ERROR);
    }
  }

  async updateAddress(userId: string, address: UserAddress): Promise<UserAddress> {
    try {
      const userRef = this.usersRef.doc(userId);
      const userDoc = await userRef.get();

      if (!userDoc.exists) {
        throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
      }

      await userRef.update({
        address,
        updatedAt: Timestamp.now()
      });

      return address;
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to update address', errorCodes.DATABASE_ERROR);
    }
  }

  async updatePreferences(userId: string, preferences: Partial<UserPreferences>): Promise<UserPreferences> {
    try {
      const userRef = this.usersRef.doc(userId);
      const userDoc = await userRef.get();

      if (!userDoc.exists) {
        throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
      }

      const userData = userDoc.data() as User;
      const updatedPreferences: UserPreferences = {
        ...userData.profile.preferences,
        ...preferences,
        language: preferences.language || userData.profile.preferences?.language || 'en',
        timezone: preferences.timezone || userData.profile.preferences?.timezone || 'UTC',
        currency: preferences.currency || userData.profile.preferences?.currency || 'USD',
        notifications: {
          email: preferences.notifications?.email ?? userData.profile.preferences?.notifications.email ?? true,
          sms: preferences.notifications?.sms ?? userData.profile.preferences?.notifications.sms ?? false,
          push: preferences.notifications?.push ?? userData.profile.preferences?.notifications.push ?? true,
        },
      };

      await userRef.update({
        'profile.preferences': updatedPreferences,
        updatedAt: Timestamp.now()
      });

      return updatedPreferences;
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to update preferences', errorCodes.DATABASE_ERROR);
    }
  }
}

export async function updateUser(uid: string, updates: Partial<User>): Promise<User> {
  try {
    const userRef = db.collection(USERS_COLLECTION)
      .where('uid', '==', uid)
      .limit(1);
    const userSnapshot = await userRef.get();

    if (userSnapshot.empty) {
      throw new Error('User not found');
    }

    const userDoc = userSnapshot.docs[0];
    const updatedUser = {
      ...userDoc.data(),
      ...updates,
      updatedAt: Timestamp.now()
    } as User;

    await userDoc.ref.update(updates);
    return { ...userDoc.data(), ...updates } as User;
  } catch (error) {
    console.error('Error updating user:', error);
    throw error;
  }
}

export default { UserUpdateService };
