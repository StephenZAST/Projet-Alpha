import { User, UserProfile, UserAddress, UserPreferences } from '../../models/user';
import { AppError, errorCodes } from '../../utils/errors';
import { NotificationService, NotificationType } from '../notifications';
import { getUserProfile, getUserById, getUsers } from './userRetrieval';
import { updateProfile, updateAddress, updatePreferences } from './userUpdate';

export class UserService {
  private notificationService = new NotificationService();

  async getUserProfile(userId: string): Promise<UserProfile> {
    try {
      const userProfile = await getUserProfile(userId);
      if (!userProfile) {
        throw new AppError(404, 'User profile not found', errorCodes.NOT_FOUND);
      }
      return userProfile;
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to fetch user profile', errorCodes.DATABASE_ERROR);
    }
  }

  async updateProfile(userId: string, updateData: Partial<UserProfile>): Promise<UserProfile> {
    try {
      const updatedProfile = await updateProfile(userId, updateData);

      // Notify user about profile update
      await this.notificationService.sendNotification(userId, {
        type: NotificationType.PROFILE_UPDATE,
        title: 'Profile Updated',
        message: 'Your profile has been successfully updated',
        data: {}
      });

      return updatedProfile;
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to update profile', errorCodes.DATABASE_ERROR);
    }
  }

  async updateAddress(userId: string, address: UserAddress): Promise<UserAddress> {
    try {
      return await updateAddress(userId, address);
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to update address', errorCodes.DATABASE_ERROR);
    }
  }

  async updatePreferences(userId: string, preferences: Partial<UserPreferences>): Promise<UserPreferences> {
    try {
      return await updatePreferences(userId, preferences);
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to update preferences', errorCodes.DATABASE_ERROR);
    }
  }

  async getUserById(userId: string): Promise<Omit<User, 'password'> | null> {
    try {
      const user = await getUserById(userId);
      if (!user) {
        return null;
      }
      return user;
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to fetch user', errorCodes.DATABASE_ERROR);
    }
  }

  async getUsers({ page = 1, limit = 10, search = '' }): Promise<{ users: (Omit<User, 'password'>)[]; total: number; page: number; totalPages: number }> {
    try {
      return await getUsers({ page, limit, search });
    } catch (error) {
      throw new AppError(500, 'Failed to fetch users', errorCodes.DATABASE_ERROR);
    }
  }
}
