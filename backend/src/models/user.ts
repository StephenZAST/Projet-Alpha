import { Timestamp } from 'firebase-admin/firestore';

export enum UserRole {
  CLIENT = 'CLIENT',
  SUPER_ADMIN = 'SUPER_ADMIN',
  SERVICE_CLIENT = 'SERVICE_CLIENT',
  SECRETAIRE = 'SECRETAIRE',
  LIVREUR = 'LIVREUR',
  SUPERVISEUR = 'SUPERVISEUR'
}

export enum UserStatus {
  PENDING = 'PENDING',
  ACTIVE = 'ACTIVE',
  SUSPENDED = 'SUSPENDED',
  DELETED = 'DELETED'
}

export enum AccountCreationMethod {
  SELF_REGISTRATION = 'SELF_REGISTRATION',
  ADMIN_CREATED = 'ADMIN_CREATED',
  AFFILIATE_REFERRAL = 'AFFILIATE_REFERRAL',
  CUSTOMER_REFERRAL = 'CUSTOMER_REFERRAL'
}

export interface Address {
  street: string;
  city: string;
  state: string;
  zipCode: string;
  country: string;
  coordinates?: {
    latitude: number;
    longitude: number;
  };
}

export interface UserAddress {
  label?: string; // e.g., "Home", "Work", "Vacation Home"
  type?: 'residential' | 'business' | 'other';
  street: string;
  unit?: string;
  city: string;
  state: string;
  zipCode: string;
  country: string;
  phoneNumber?: string;
  instructions?: string;
  isDefault?: boolean;
  coordinates?: {
    latitude: number;
    longitude: number;
  };
  validatedAt?: Date;
  lastUsed?: Date;
}

export interface UserPreferences {
  theme?: 'light' | 'dark' | 'system';
  currency?: string;
  measurementUnit?: 'metric' | 'imperial';
  communicationFrequency?: 'daily' | 'weekly' | 'monthly' | 'never';
  orderNotifications?: {
    confirmation: boolean;
    statusUpdates: boolean;
    delivery: boolean;
  };
  marketingPreferences?: {
    email: boolean;
    sms: boolean;
    push: boolean;
    promotions: boolean;
    newsletters: boolean;
  };
  servicePreferences?: {
    defaultServiceType?: string;
    preferredPickupTime?: string;
    preferredDeliveryTime?: string;
    specialInstructions?: string;
  };
}

export interface UserProfile {
  firstName: string;
  lastName: string;
  displayName?: string;
  email: string;
  phoneNumber: string;
  avatar?: string;
  dateOfBirth?: Date;
  gender?: 'male' | 'female' | 'other' | 'prefer_not_to_say';
  language?: string;
  timezone?: string;
  bio?: string;
  occupation?: string;
  company?: string;
  website?: string;
  socialLinks?: {
    facebook?: string;
    twitter?: string;
    instagram?: string;
    linkedin?: string;
  };
  preferences?: UserPreferences;
  notificationSettings?: {
    email: boolean;
    push: boolean;
    sms: boolean;
    marketing: boolean;
  };
  address?: UserAddress;
  defaultAddress?: UserAddress;
  lastUpdated: Date;
}

export interface User {
  id: string;
  uid: string; // Firebase Auth UID
  profile: UserProfile;
  role: UserRole;
  status: UserStatus;
  creationMethod: AccountCreationMethod;
  emailVerified: boolean;
  emailVerificationToken?: string;
  emailVerificationExpires?: Date;
  passwordResetToken?: string;
  passwordResetExpires?: Date;
  loyaltyPoints: number;
  referralCode?: string;
  affiliateId?: string;
  sponsorId?: string;
  lastLogin?: Date;
  zone?: string;
  createdBy?: string;
  defaultItems?: Array<{ id: string; quantity: number }>;
  defaultInstructions?: string;
  createdAt: Date;
  updatedAt: Date;
}

export type CreateUserInput = Omit<User, 'id' | 'createdAt' | 'updatedAt'> & {
  id?: string;
  createdAt?: Date;
  updatedAt?: Date;
};
