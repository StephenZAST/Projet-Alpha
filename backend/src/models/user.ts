import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';
import { OrderItem } from './order';

export enum UserRole {
  ADMIN = 'admin',
  CLIENT = 'client',
  AFFILIATE = 'affiliate'
}

export enum UserStatus {
  PENDING = 'pending',
  ACTIVE = 'active',
  DELETED = 'deleted'
}

export enum AccountCreationMethod {
  SELF_REGISTRATION = 'self_registration',
  ADMIN_CREATED = 'admin_created',
  AFFILIATE_REFERRAL = 'affiliate_referral',
  CUSTOMER_REFERRAL = 'customer_referral'
}

export interface UserAddress {
  street: string;
  city: string;
  state: string;
  zip: string;
  country: string;
}

export interface UserPreferences {
  notifications: boolean;
  defaultItems: OrderItem[];
  defaultInstructions: string;
}

export interface UserProfile {
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber: string;
  address: UserAddress | null;
  defaultInstructions: string | null;
  defaultItems: OrderItem[] | null;
  lastUpdated: string | null;
  preferences: UserPreferences | null;
}

export interface User {
  id: string;
  uid: string;
  profile: UserProfile;
  role: UserRole;
  status: UserStatus;
  creationMethod: AccountCreationMethod;
  emailVerified: boolean;
  loyaltyPoints: number;
  defaultItems: OrderItem[];
  defaultInstructions: string;
  createdAt: string;
  updatedAt: string;
  phoneNumber: string | null;
  displayName: string | null;
  email: string | null;
  lastName: string | null;
  firstName: string | null;
}

// Use Supabase to store user data
const usersTable = 'users';

// Function to get user data
export async function getUser(id: string): Promise<User | null> {
  const { data, error } = await supabase.from(usersTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch user', 'INTERNAL_SERVER_ERROR');
  }

  return data as User;
}

// Function to create user
export async function createUser(userData: User): Promise<User> {
  const { data, error } = await supabase.from(usersTable).insert([userData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create user', 'INTERNAL_SERVER_ERROR');
  }

  return data as User;
}

// Function to update user
export async function updateUser(id: string, userData: Partial<User>): Promise<User> {
  const currentUser = await getUser(id);

  if (!currentUser) {
    throw new AppError(404, 'User not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(usersTable).update(userData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update user', 'INTERNAL_SERVER_ERROR');
  }

  return data as User;
}

// Function to delete user
export async function deleteUser(id: string): Promise<void> {
  const user = await getUser(id);

  if (!user) {
    throw new AppError(404, 'User not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(usersTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete user', 'INTERNAL_SERVER_ERROR');
  }
}
