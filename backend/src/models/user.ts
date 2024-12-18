import { Timestamp } from 'firebase-admin/firestore';
import { OrderItem } from './order';

export enum UserRole {
  SUPER_ADMIN_MASTER = 'super_admin_master', // Unique account
  SUPER_ADMIN = 'super_admin',               // Secondary super admins
  ADMIN = 'ADMIN',
  SECRETAIRE = 'SECRETAIRE',
  DELIVERY = 'DELIVERY',
  CUSTOMER_SERVICE = 'customer_service',
  SUPERVISEUR = 'SUPERVISEUR',
  CLIENT = 'CLIENT',
  SECRETARY = "SECRETARY",
  SERVICE_CLIENT = "SERVICE_CLIENT",
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
  defaultInstructions?: string;
  defaultItems?: OrderItem[];
}

export interface User {
  id: string;
  uid: string;
  firstName?: string;
  lastName?: string;
  email?: string;
  phone?: string;
  role: UserRole;
  profile?: Partial<UserProfile>;
  status: UserStatus;
  address?: string;
  creationMethod: AccountCreationMethod;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  fcmToken?: string;
}

export interface CreateUserInput {
  uid: string;
  firstName: string;
  lastName: string;
  email: string;
  phone?: string;
  role: UserRole;
  status: UserStatus;
  creationMethod: AccountCreationMethod;
  password?: string;
  profile?: Partial<UserProfile>;
}

export interface UpdateUserInput {
  firstName?: string;
  lastName?: string;
  email?: string;
  phone?: string;
  role?: UserRole;
  profile?: Partial<UserProfile>;
  status?: UserStatus;
  address?: string;
  fcmToken?: string;
}
