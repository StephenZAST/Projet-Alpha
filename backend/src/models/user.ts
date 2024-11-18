// src/models/user.ts
import { Timestamp } from 'firebase-admin/firestore';

export interface User {
  uid: string;
  email: string;
  displayName: string;
  phoneNumber?: string;
  password: string;  // Will be hashed
  address?: Address;
  defaultAddress?: Address;
  role: UserRole;
  status: UserStatus;
  affiliateId?: string;        // If registered through affiliate
  sponsorId?: string;         // If registered through customer sponsorship
  sponsorCode?: string;       // Customer's own sponsorship code
  createdBy?: string;         // UID of admin who created the account (if applicable)
  creationMethod: AccountCreationMethod;
  emailVerified: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  lastLogin?: Timestamp;
  loyaltyPoints: number;
  subscriptionType?: SubscriptionType;
  defaultServicePreferences?: ServicePreferences;
  activeOffers?: string[];
  zone?: string;              // Zone/quartier pour la gestion des livraisons
  passwordResetToken?: string;
  passwordResetExpires?: Timestamp;
  verificationToken?: string;
  verificationExpires?: Timestamp;
}

export enum UserRole {
  CLIENT = 'client',
  SUPER_ADMIN = 'super_admin',
  SERVICE_CLIENT = 'service_client',
  SECRETAIRE = 'secretaire',
  LIVREUR = 'livreur',
  SUPERVISEUR = 'superviseur'
}

export enum UserStatus {
  PENDING = 'pending',          // Email not verified
  ACTIVE = 'active',           // Email verified and account active
  SUSPENDED = 'suspended',      // Account suspended
  DEACTIVATED = 'deactivated'  // Account deactivated by user or admin
}

export enum AccountCreationMethod {
  SELF_REGISTRATION = 'self_registration',    // Customer registered themselves
  ADMIN_CREATED = 'admin_created',           // Created by admin/secretary
  AFFILIATE_REFERRAL = 'affiliate_referral', // Through affiliate link/code
  CUSTOMER_REFERRAL = 'customer_referral'    // Through customer sponsorship
}

export enum SubscriptionType {
  NONE = 'none',
  WEEKLY = 'weekly',
  MONTHLY = 'monthly'
}

export interface ServicePreferences {
  defaultService: ServiceType;
  priceRange: PriceRange;
  weightLimit?: number;
}

export enum ServiceType {
  BLANCHISSERIE_COMPLETE = 'blanchisserie_complete',
  REPASSAGE = 'repassage',
  NETTOYAGE_SEC = 'nettoyage_sec'
}

export enum PriceRange {
  STANDARD = 'standard',
  PREMIUM = 'premium',
  ECONOMIQUE = 'economique'
}

export interface Address {
  street: string;
  city: string;
  postalCode: string;
  country: string;
  quartier: string;
  location: GeoLocation;
  additionalInfo?: string;
}

export interface GeoLocation {
  latitude: number;
  longitude: number;
  zoneId: string;
}
