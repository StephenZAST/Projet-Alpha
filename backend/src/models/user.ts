import { Timestamp } from 'firebase-admin/firestore';

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
  lastUpdated: Timestamp | null;
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
  createdAt: Timestamp;
  updatedAt: Timestamp;
  phoneNumber: string | null;
  displayName: string | null;
  email: string | null;
  lastName: string | null;
  firstName: string | null;
}

export interface OrderItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
  itemType: string;
  priceType: string;
}

export interface OrderInput {
  userId: string;
  items: OrderItem[];
  totalAmount: number;
  paymentMethod: string;
  type?: OrderType;
  oneClickOrder?: boolean;
  orderNotes?: string;
}

export interface CreateUserInput {
  uid?: string;
  profile: {
    firstName: string;
    lastName: string;
    email: string;
    phoneNumber: string;
  };
  password: string;
  role?: UserRole;
  status?: UserStatus;
  creationMethod?: AccountCreationMethod;
}

export enum OrderStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  DELIVERED = 'delivered',
  CANCELLED = 'cancelled'
}

export enum OrderType {
  STANDARD = 'standard',
  ONE_CLICK = 'one_click'
}
