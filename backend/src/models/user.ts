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

export interface User {
  id: string;
  uid: string; // Firebase Auth UID
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  displayName?: string;
  phoneNumber: string;
  address?: Address;
  defaultAddress?: Address;
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
