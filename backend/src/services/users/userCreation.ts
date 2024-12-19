import { supabase } from '../../config/supabase';
import { User, UserRole, UserStatus, AccountCreationMethod, CreateUserInput, UserProfile } from '../../models/user';
import { AppError, errorCodes } from '../../utils/errors';
import { getUserByEmail } from '../users/userRetrieval';
import { AuthError } from '@supabase/supabase-js';

const SALT_ROUNDS = 10;
const usersTable = 'users';

interface CreateUserResult {
  user: User;
  profile: UserProfile;
}

export const createUser = async (userData: CreateUserInput): Promise<User> => {
  try {
    // Validate input data
    if (!userData.email || !userData.password) {
      throw new AppError(400, 'Email and password are required', errorCodes.INVALID_USER_DATA);
    }

    // Create auth user
    const { data: authUser, error: authError } = await supabase.auth.signUp({
      email: userData.email,
      password: userData.password,
    });

    if (authError) {
      console.error('Auth Error:', authError);
      throw new AppError(400, `Authentication error: ${authError.message}`, errorCodes.AUTH_ERROR);
    }

    if (!authUser.user) {
      throw new AppError(400, 'User creation failed', errorCodes.USER_ERROR);
    }

    // Prepare profile data
    const profileData = {
      id: authUser.user.id,
      email: userData.email,
      first_name: userData.firstName,
      last_name: userData.lastName,
      phone: userData.phone || null,
      role: userData.role || UserRole.CLIENT,
      status: userData.status || UserStatus.PENDING,
      creation_method: userData.creationMethod,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    };

    // Create profile
    const { data: profile, error: profileError } = await supabase
      .from('profiles')
      .insert([profileData])
      .select()
      .single();

    if (profileError) {
      // Cleanup auth user if profile creation fails
      await supabase.auth.admin.deleteUser(authUser.user.id);
      console.error('Profile Error:', profileError);
      throw new AppError(400, 'Profile creation failed', errorCodes.PROFILE_ERROR);
    }

    // Return formatted user object
    const user: User = {
      id: authUser.user.id,
      uid: authUser.user.id,
      role: profileData.role,
      status: profileData.status,
      createdAt: new Date(profileData.created_at),
      updatedAt: new Date(profileData.updated_at),
      profile: {
        firstName: profileData.first_name,
        lastName: profileData.last_name,
        email: profileData.email,
        phone: profileData.phone || undefined
      },
      creationMethod: AccountCreationMethod.SELF_REGISTERED
    };

    return user;
  } catch (error) {
    console.error('Creation Error:', error);
    if (error instanceof AppError) {
      throw error;
    }    throw new AppError(500, 'Failed to create user', errorCodes.USER_CREATION_ERROR);  }};export async function registerCustomer(  userData: CreateUserInput,  method: AccountCreationMethod): Promise<User> {  if (!userData.profile || !userData.profile.email) {    throw new Error('User profile or email is required');
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
