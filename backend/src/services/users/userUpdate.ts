import { db, CollectionReference } from '../../config/firebase';
import { User, UserProfile, UserAddress, UserPreferences } from '../../models/user';
import { AppError, errorCodes } from '../../utils/errors';
import { NotificationService } from '../notifications';

const USERS_COLLECTION = 'users';

export async function updateProfile(userId: string, updateData: Partial<UserProfile>): Promise<UserProfile> {
  try {
    const userRef = db.collection(USERS_COLLECTION).doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    const updatedData = {
      ...updateData,
      lastUpdated: new Date()
    };

    await userRef.update({
      profile: updatedData
    });

    // Notify user about profile update
    const notificationService = new NotificationService();
    await notificationService.sendNotification(userId, {
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
    };
  } catch (error) {
    if (error instanceof AppError) throw error;
    throw new AppError(500, 'Failed to update profile', errorCodes.DATABASE_ERROR);
  }
}

export async function updateAddress(userId: string, address: UserAddress): Promise<UserAddress> {
  try {
    const userRef = db.collection(USERS_COLLECTION).doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    await userRef.update({
      address,
      updatedAt: new Date()
    });

    return address;
  } catch (error) {
    if (error instanceof AppError) throw error;
    throw new AppError(500, 'Failed to update address', errorCodes.DATABASE_ERROR);
  }
}

export async function updatePreferences(userId: string, preferences: Partial<UserPreferences>): Promise<UserPreferences> {
  try {
    const userRef = db.collection(USERS_COLLECTION).doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    const userData = userDoc.data() as User;
    const updatedPreferences = {
      ...userData.profile.preferences,
      ...preferences,
    };

    await userRef.update({
      'profile.preferences': updatedPreferences,
      updatedAt: new Date()
    });

    return updatedPreferences;
  } catch (error) {
    if (error instanceof AppError) throw error;
    throw new AppError(500, 'Failed to update preferences', errorCodes.DATABASE_ERROR);
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
      updatedAt: new Date()
    } as User;

    await userDoc.ref.update(updates);
    return { ...userDoc.data(), ...updates } as User;
  } catch (error) {
    console.error('Error updating user:', error);
    throw error;
  }
}
