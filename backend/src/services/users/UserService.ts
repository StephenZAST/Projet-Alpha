import { db, auth, CollectionReference, Timestamp } from '../../config/firebase';
import { User, UserRole, UserStatus, UserProfile, UserAddress, UserPreferences } from '../../models/user';
import { AppError, errorCodes } from '../../utils/errors';
import { NotificationService } from '../users/userVerification';

const USERS_COLLECTION = 'users';

export class UserService {
  private usersRef: CollectionReference = db.collection(USERS_COLLECTION);
  private notificationService = new NotificationService();

  async getUserProfile(userId: string): Promise<UserProfile> {
    try {
      const userDoc = await this.usersRef.doc(userId).get();

      if (!userDoc.exists) {
        throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
      }

      const userData = userDoc.data() as User;
      return {
        ...userData.profile,
        lastUpdated: userData.updatedAt
      };
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to fetch user profile', errorCodes.DATABASE_ERROR);
    }
  }

  async updateProfile(userId: string, updateData: Partial<UserProfile>): Promise<UserProfile> {
    try {
      const userRef = this.usersRef.doc(userId);
      const userDoc = await userRef.get();

      if (!userDoc.exists) {
        throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
      }

      const updatedData = {
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
      };
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
        notifications: preferences.notifications ?? userData.profile.preferences?.notifications ?? false,
        defaultItems: preferences.defaultItems ?? userData.profile.preferences?.defaultItems ?? [],
        defaultInstructions: preferences.defaultInstructions ?? userData.profile.preferences?.defaultInstructions ?? ''
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

  async getUserById(userId: string): Promise<User> {
    try {
      const userDoc = await this.usersRef.doc(userId).get();

      if (!userDoc.exists) {
        throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
      }

      return {
        ...(userDoc.data() as User)
      };
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to fetch user', errorCodes.DATABASE_ERROR);
    }
  }

  async getUsers({ page = 1, limit = 10, search = '' }): Promise<{ users: User[], total: number, page: number, totalPages: number }> {
    try {
      const totalDocs = await this.usersRef.count().get();
      const total = totalDocs.data().count;
      const totalPages = Math.ceil(total / limit);

      let snapshot = this.usersRef
        .orderBy('createdAt', 'desc')
        .offset((page - 1) * limit)
        .limit(limit);

      if (search) {
        snapshot = snapshot.where('profile.displayName', '>=', search)
          .where('profile.displayName', '<=', search + '\uf8ff');
      }

      const users = (await snapshot.get()).docs.map(doc => (doc.data() as User));

      return {
        users,
        total,
        page,
        totalPages
      };
    } catch (error) {
      throw new AppError(500, 'Failed to fetch users', errorCodes.DATABASE_ERROR);
    }
  }
}
