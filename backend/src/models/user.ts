import { OrderItem } from './order';

export enum UserRole {
  ADMIN = 'admin',
  CLIENT = 'client',
  AFFILIATE = 'affiliate',
  SECRETARY = 'secretary', // Added this role
  SUPER_ADMIN = 'SUPER_ADMIN'
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

export interface CreateUserInput {
  uid?: string;
  profile: UserProfile;
  role?: UserRole;
  status?: UserStatus;
  creationMethod?: AccountCreationMethod;
  password: string;
}
