// src/models/user.ts
export interface User {
  uid: string;
  email: string;
  displayName: string;
  phoneNumber?: string;
  address: Address;
  role: UserRole;
  affiliateId?: string;
  creationDate: Date;
  lastLogin: Date;
  loyaltyPoints?: number;
}

export enum UserRole {
  CLIENT = 'client',
  AFFILIATE = 'affiliate',
  ADMIN = 'admin',
  SECRETARY = 'secretary',
  DELIVERY = 'delivery'
}

export interface Address {
  street: string;
  city: string;
  postalCode: string;
  country: string;
  additionalInfo?: string;
}

