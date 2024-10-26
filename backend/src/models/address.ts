export interface Address {
  id: string;
  userId: string;
  type: AddressType;
  label: string;
  coordinates: GeoPoint;
  formattedAddress: string;
  details?: string;
  isDefault: boolean;
  createdAt: Date;
}

export interface GeoPoint {
  latitude: number;
  longitude: number;
}

export enum AddressType {
  HOME = 'home',
  OFFICE = 'office',
  OTHER = 'other'
}
