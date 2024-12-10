import { Timestamp } from 'firebase/firestore';

export enum UserRole {
  SUPER_ADMIN = 'super_admin',
  ADMIN = 'admin',
  CLIENT = 'client',
  DELIVERY_PERSONNEL = 'delivery_personnel',
  AFFILIATE = 'affiliate',
}

export enum UserStatus {
  ACTIVE = 'active',
  PENDING = 'pending',
  SUSPENDED = 'suspended',
  DELETED = 'deleted',
}

export enum AccountCreationMethod {
  SELF_REGISTRATION = 'self_registration',
  ADMIN_INVITE = 'admin_invite',
  SOCIAL_MEDIA = 'social_media',
}

export interface UserAddress {
  street: string;
  city: string;
  state: string;
  zipCode: string;
  country: string;
  phoneNumber: string;
}

export interface UserPreferences {
  language: string;
  timezone: string;
  currency: string;
  notifications: {
    email: boolean;
    sms: boolean;
    push: boolean;
  };
}

export interface UserProfile {
  firstName: string;
  lastName: string;
  email: string;
  phoneNumber: string;
  address?: UserAddress;
  preferences?: UserPreferences;
  profilePictureUrl?: string;
  lastUpdated: Timestamp;
  defaultItems?: any[];
  defaultInstructions?: string;
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
  createdAt: Timestamp;
  updatedAt: Timestamp;
  phoneNumber?: string;
  displayName?: string;
  email?: string;
  lastName?: string;
  firstName?: string;
}

export interface CreateUserInput {
  uid?: string;
  profile: {
    firstName: string;
    lastName: string;
    email: string;
    phoneNumber: string;
  };
  password?: string;
  role?: UserRole;
  status?: UserStatus;
  creationMethod?: AccountCreationMethod;
}
