import supabase from '../../config/supabase';
import { User, UserRole, UserStatus, AccountCreationMethod, CreateUserInput, UserProfile, UserAddress, UserPreferences } from '../../models/user';
import { hash } from 'bcrypt';
import { generateToken } from '../../utils/tokens';
import { sendVerificationEmail } from '../users/userVerification';
import { AppError, errorCodes } from '../../utils/errors';
import { getUserByEmail } from '../users/userRetrieval';

const SALT_ROUNDS = 10;
const usersTable = 'users';

export async function createUser(userData: CreateUserInput): Promise<User> {
  try {
    const now = new Date();

    if (!userData.password) {
      throw new Error('Password is required');
    }

    // Hash the password
    const hashedPassword = await hash(userData.password, SALT_ROUNDS);

    const newUser: User = {
      id: '',
      uid: '',
      profile: {
        ...userData.profile,
        address: undefined,
        preferences: {
          notifications: {
            email: false,
            sms: false,
            push: false,
          },
          language: 'en',
        }
      },
      role: userData.role || UserRole.CLIENT,
      status: UserStatus.PENDING,
      creationMethod: userData.creationMethod || AccountCreationMethod.SELF_REGISTERED,
      createdAt: now,
      updatedAt: now,
    };

    const { data, error } = await supabase.from(usersTable).insert([newUser]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create user', 'INTERNAL_SERVER_ERROR');
    }

    // Send verification email
    const verificationToken = await generateToken();
    if (!data.profile || !data.profile.email) {
      throw new Error('User profile or email is undefined');
    }
    await sendVerificationEmail(data.profile.email, verificationToken);

    return data;
  } catch (error) {
    console.error('Error creating user:', error);
    throw error;
  }
}

export async function registerCustomer(
  userData: CreateUserInput,
  method: AccountCreationMethod
): Promise<User> {
  if (!userData.profile || !userData.profile.email) {
    throw new Error('User profile or email is required');
  }

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

export { getUserByEmail };
