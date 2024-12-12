import { Timestamp } from 'firebase-admin/firestore';

export enum OfferType {
  PERCENTAGE = 'percentage',
  FIXED_AMOUNT = 'fixed_amount',
  FREE_SERVICE = 'free_service',
  BUY_ONE_GET_ONE = 'buy_one_get_one',
  LOYALTY_POINTS = 'loyalty_points'
}

export enum UserOfferType {
  ALL = 'all',
  NEW = 'new',
  EXISTING = 'existing',
  PREMIUM = 'premium',
  VIP = 'vip'
}

export interface Offer {
  id?: string;
  code: string;
  type: OfferType;
  value: number;
  minOrderValue?: number;
  maxDiscount?: number;
  startDate: string;
  endDate: string;
  description: string;
  termsAndConditions: string;
  applicableServices: string[];
  userType: UserOfferType[];
  isActive: boolean;
  usageLimit?: number;
  usageCount: number;
  createdAt: string;
  updatedAt: string;
}
