import { db } from '../config/firebase';
import { User, UserProfile, UserAddress, UserPreferences } from '../models/user';
import { AppError, errorCodes } from '../utils/errors';
import { NotificationService } from './notifications';
import { UserUpdateService, updateUser } from './users/userUpdate';
import { createUser, registerCustomer } from './users/userCreation';
import { verifyEmail, requestPasswordReset, resetPassword } from './users/userAuthentication';
import { deleteUser } from './users/userDeletion';
import { getUsers } from './users/userListing';
import { getUserByEmail, getUserById, getUserProfile, getUserProfileByUid } from './users/userRetrieval';

const USERS_COLLECTION = 'users';

export class UserService {
  private usersRef = db.collection(USERS_COLLECTION);
  private userUpdateService = new UserUpdateService();

  async getUserProfile(userId: string): Promise<UserProfile> {
    return getUserProfile(userId);
  }

  async updateProfile(userId: string, updateData: Partial<UserProfile>): Promise<UserProfile> {
    return this.userUpdateService.updateProfile(userId, updateData);
  }

  async updateAddress(userId: string, address: UserAddress): Promise<UserAddress> {
    return this.userUpdateService.updateAddress(userId, address);
  }

  async updatePreferences(userId: string, preferences: Partial<UserPreferences>): Promise<UserPreferences> {
    return this.userUpdateService.updatePreferences(userId, preferences);
  }

  async getUserById(userId: string): Promise<User | null> {
    return getUserById(userId);
  }

  async getUsers(params: { page?: number, limit?: number, search?: string }): Promise<{ users: User[], total: number, page: number, totalPages: number }> {
    return getUsers(params);
  }
}

export {
  createUser,
  registerCustomer,
  verifyEmail,
  requestPasswordReset,
  resetPassword,
  getUserByEmail,
  getUserById,
  getUserProfile,
  getUserProfileByUid,
  updateUser,
  deleteUser
};
