import { Timestamp } from 'firebase-admin/firestore';

export interface Address {
  formattedAddress: string | undefined;
  id?: string;
  userId?: string;
  type?: 'home' | 'work' | 'other';
  label?: string;
  street: string;
  city: string;
  state: string;
  postalCode: string;
  country: string;
  quartier?: string;
  coordinates?: {
    latitude: number;
    longitude: number;
  };
  zoneId?: string;
  isDefault?: boolean;
  additionalInfo?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface AddressInput extends Omit<Address, 'id' | 'createdAt' | 'updatedAt'> {
  id?: string;
  createdAt?: Date;
  updatedAt?: Date;
}
