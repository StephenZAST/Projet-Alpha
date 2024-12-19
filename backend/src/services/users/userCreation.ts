import { supabase } from '../../config/supabase';
import { User, UserRole, UserStatus, AccountCreationMethod, CreateUserInput, UserProfile, UserAddress, UserPreferences } from '../../models/user';
import { hash } from 'bcrypt';
import { generateToken } from '../../utils/tokens';
import { sendVerificationEmail } from '../users/userVerification';
import { AppError, errorCodes } from '../../utils/errors';
import { getUserByEmail } from '../users/userRetrieval';

const SALT_ROUNDS = 10;
const usersTable = 'users';

export const createUser = async (userData: any) => {
  try {
    // Create auth user
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: userData.email,
      password: userData.password,
    });

    if (authError) {
      console.error('Auth Error:', authError);
      throw new AppError(400, `Authentication error: ${authError.message}`, 'AUTH_ERROR');
    }

    // Create user profile
    const { data: profileData, error: profileError } = await supabase
      .from('users')
      .insert([
        {
          id: authData.user?.id,
          email: userData.email,
          display_name: userData.displayName,
          phone_number: userData.phoneNumber,
          address: userData.address,
          affiliate_code: userData.affiliateCode,
          sponsor_code: userData.sponsorCode,
          creation_method: userData.creationMethod,
          profile: userData.profile
        }
      ])
      .select()
      .single();

    if (profileError) {
      console.error('Profile Error:', profileError);
      // Cleanup auth user if profile creation fails
      await supabase.auth.admin.deleteUser(authData.user?.id as string);
      throw new AppError(400, `Profile creation error: ${profileError.message}`, 'PROFILE_ERROR');
    }

    return profileData;
  } catch (error) {
    console.error('Creation Error:', error);
    if (error instanceof AppError) {
      throw error;
    }
    if (error instanceof Error) {
      throw new AppError(500, `Failed to create user: ${error.message}`, 'INTERNAL_SERVER_ERROR');
    }
    throw new AppError(500, 'Failed to create user: An unknown error occurred.', 'INTERNAL_SERVER_ERROR');
  }
};

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
