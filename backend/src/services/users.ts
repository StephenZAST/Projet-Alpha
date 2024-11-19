import { db, auth, CollectionReference } from '../config/firebase';
import { User, UserRole, UserStatus, AccountCreationMethod, CreateUserInput, UserProfile, UserAddress, UserPreferences } from '../models/user';
import { hash } from 'bcrypt';
import { generateToken } from '../utils/tokens';
import { sendVerificationEmail, sendPasswordResetEmail, sendWelcomeEmail } from './emailService';
import { AppError, errorCodes } from '../utils/errors';
import { NotificationService } from './notifications';

const SALT_ROUNDS = 10;
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
        lastUpdated: new Date()
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
        updatedAt: new Date()
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

      const users = (await snapshot.get()).docs.map(doc => ({
        ...(doc.data() as User)
      }));

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

export async function createUser(userData: CreateUserInput): Promise<User> {
  try {
    const userRef = db.collection(USERS_COLLECTION).doc();
    const now = new Date();

    // Create Firebase Auth user if not exists
    let firebaseUser;
    if (!userData.uid) {
      firebaseUser = await auth.createUser({
        email: userData.profile.email,
        password: userData.password,
        displayName: `${userData.profile.firstName} ${userData.profile.lastName}`,
        phoneNumber: userData.profile.phoneNumber
      });
    }

    const hashedPassword = await hash(userData.password, SALT_ROUNDS);

    const newUser: User = {
      id: userRef.id,
      uid: userData.uid || firebaseUser?.uid || userRef.id,
      profile: {
        ...userData.profile,
        lastUpdated: now
      },
      role: userData.role || UserRole.CLIENT,
      status: UserStatus.PENDING,
      creationMethod: userData.creationMethod || AccountCreationMethod.SELF_REGISTRATION,
      emailVerified: false,
      loyaltyPoints: 0,
      defaultItems: [],
      defaultInstructions: '',
      createdAt: now,
      updatedAt: now,
    };

    await userRef.set(newUser);

    // Send verification email
    const verificationToken = await generateToken();
    await sendVerificationEmail(newUser.profile.email, verificationToken);

    return newUser;
  } catch (error) {
    console.error('Error creating user:', error);
    throw error;
  }
}

export async function registerCustomer(
  userData: CreateUserInput,
  method: AccountCreationMethod
): Promise<User> {
  const existingUser = await getUserByEmail(userData.profile.email);
  if (existingUser) {
    throw new Error('Email already registered');
  }

  return createUser({
    ...userData,
    role: UserRole.CLIENT,
    status: UserStatus.PENDING,
    creationMethod: method
  });
}

export async function verifyEmail(token: string): Promise<void> {
  const userSnapshot = await db.collection(USERS_COLLECTION)
    .where('emailVerificationToken', '==', token)
    .where('emailVerificationExpires', '>', new Date())
    .limit(1)
    .get();

  if (userSnapshot.empty) {
    throw new Error('Invalid or expired verification token');
  }

  const userDoc = userSnapshot.docs[0];
  const user = userDoc.data() as User;

  await userDoc.ref.update({
    emailVerified: true,
    status: UserStatus.ACTIVE,
    emailVerificationToken: null,
    emailVerificationExpires: null,
    updatedAt: new Date()
  });

  await sendWelcomeEmail(user.profile.email, user.profile.firstName);
}

export async function requestPasswordReset(email: string): Promise<void> {
  const user = await getUserByEmail(email);
  if (!user) {
    throw new Error('User not found');
  }

  const resetToken = generateToken();
  const resetExpires = new Date(Date.now() + 60 * 60 * 1000); // 1 hour

  await db.collection(USERS_COLLECTION).doc(user.id).update({
    passwordResetToken: resetToken,
    passwordResetExpires: resetExpires,
    updatedAt: new Date()
  });

  await sendPasswordResetEmail(email, resetToken);
}

export async function resetPassword(token: string, newPassword: string): Promise<void> {
  const userSnapshot = await db.collection(USERS_COLLECTION)
    .where('passwordResetToken', '==', token)
    .where('passwordResetExpires', '>', new Date())
    .limit(1)
    .get();

  if (userSnapshot.empty) {
    throw new Error('Invalid or expired reset token');
  }

  const hashedPassword = await hash(newPassword, SALT_ROUNDS);

  await userSnapshot.docs[0].ref.update({
    password: hashedPassword,
    passwordResetToken: null,
    passwordResetExpires: null,
    updatedAt: new Date()
  });
}

export async function getUserByEmail(email: string): Promise<User | null> {
  const userSnapshot = await db.collection(USERS_COLLECTION)
    .where('profile.email', '==', email)
    .limit(1)
    .get();

  if (userSnapshot.empty) {
    return null;
  }

  const userData = userSnapshot.docs[0].data() as User;
  return {
    ...userData
  };
}

export async function getUserById(id: string): Promise<User | null> {
  const userDoc = await db.collection(USERS_COLLECTION).doc(id).get();

  if (!userDoc.exists) {
    return null;
  }

  const userData = userDoc.data() as User;
  return {
    ...userData
  };
}

export async function getUserProfile(uid: string): Promise<User | null> {
  try {
    const userSnapshot = await db.collection(USERS_COLLECTION)
      .where('uid', '==', uid)
      .limit(1)
      .get();

    if (userSnapshot.empty) {
      return null;
    }

    const userData = userSnapshot.docs[0].data() as User;
    return {
      ...userData
    };
  } catch (error) {
    console.error('Error getting user profile:', error);
    throw error;
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

export async function deleteUser(uid: string): Promise<void> {
  try {
    const userRef = db.collection(USERS_COLLECTION)
      .where('uid', '==', uid)
      .limit(1);
    const userSnapshot = await userRef.get();

    if (userSnapshot.empty) {
      throw new Error('User not found');
    }

    await userSnapshot.docs[0].ref.update({
      status: UserStatus.DELETED,
      updatedAt: new Date()
    });

    // Delete from Firebase Auth
    try {
      await auth.deleteUser(uid);
    } catch (error) {
      console.error('Error deleting Firebase Auth user:', error);
    }
  } catch (error) {
    console.error('Error deleting user:', error);
    throw error;
  }
}

export { sendVerificationEmail };
