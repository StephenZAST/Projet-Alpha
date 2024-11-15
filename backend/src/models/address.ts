import { Timestamp } from 'firebase-admin/firestore';

export interface Address {
  id?: string;
  userId: string;
  type: AddressType;
  label: string;
  streetNumber?: string;
  street: string;
  apartment?: string;
  floor?: string;
  building?: string;
  city: string;
  state: string;
  country: string;
  postalCode: string;
  coordinates: GeoPoint;
  formattedAddress: string;
  additionalDetails?: string;
  deliveryInstructions?: string;
  contactName: string;
  contactPhone: string;
  alternatePhone?: string;
  isDefault: boolean;
  isVerified: boolean;
  verifiedAt?: Timestamp;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface GeoPoint {
  latitude: number;
  longitude: number;
}

export enum AddressType {
  HOME = 'HOME',
  OFFICE = 'OFFICE',
  BUSINESS = 'BUSINESS',
  APARTMENT = 'APARTMENT',
  OTHER = 'OTHER'
}

export interface AddressValidation {
  id?: string;
  addressId: string;
  isValid: boolean;
  validatedBy: string;
  validatedAt: Timestamp;
  issues?: AddressValidationIssue[];
  notes?: string;
}

export interface AddressValidationIssue {
  type: AddressValidationIssueType;
  description: string;
  severity: 'LOW' | 'MEDIUM' | 'HIGH';
  field?: string;
}

export enum AddressValidationIssueType {
  INVALID_FORMAT = 'INVALID_FORMAT',
  NOT_FOUND = 'NOT_FOUND',
  INCOMPLETE = 'INCOMPLETE',
  AMBIGUOUS = 'AMBIGUOUS',
  RESTRICTED_AREA = 'RESTRICTED_AREA',
  OUT_OF_COVERAGE = 'OUT_OF_COVERAGE'
}
