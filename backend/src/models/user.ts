import { Timestamp } from 'firebase-admin/firestore';

export enum UserRole {
  SUPER_ADMIN = 'SUPER_ADMIN',
  ADMIN = 'ADMIN',
  DELIVERY = 'DELIVERY',
  CLIENT = 'CLIENT',
  SERVICE_CLIENT = 'SERVICE_CLIENT',
  SECRETAIRE = 'SECRETAIRE',
  SUPERVISEUR = 'SUPERVISEUR',
}

export enum UserStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  SUSPENDED = 'SUSPENDED',
  PENDING = 'PENDING',
}

export enum AccountCreationMethod {
  SELF_REGISTERED = 'SELF_REGISTERED',
  REFERRED = 'REFERRED',
  ADMIN_CREATED = 'ADMIN_CREATED',
  AFFILIATE_CREATED = 'AFFILIATE_CREATED'
}

export interface UserAddress {
  street: string;
  city: string;
  state: string;
  zip: string;
  country: string;
  coordinates?: {
    latitude: number;
    longitude: number;
  };
}

export interface UserPreferences {
  notifications: {
    email: boolean;
    sms: boolean;
    push: boolean;
  };
  language: string;
}

export interface UserProfile {
  firstName: string;
  lastName: string;
  email: string;
  phone?: string;
  address?: UserAddress;
  profilePicture?: string;
  preferences?: UserPreferences;
}

export interface User {
  id: string;
  uid: string;
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  role: UserRole;
  profile?: string;
  status: UserStatus;
  address?: string;
  creationMethod: AccountCreationMethod;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  fcmToken?: string;
}

export interface CreateUserInput {
  firstName: string;
  lastName: string;
  email: string;
  phone?: string;
  role: UserRole;
  status: UserStatus;
  creationMethod: AccountCreationMethod;
  password?: string;
}

export interface UpdateUserInput {
  firstName?: string;
  lastName?: string;
  email?: string;
  phone?: string;
  role?: UserRole;
  profile?: string;
  status?: UserStatus;
  address?: string;
  fcmToken?: string;
}
