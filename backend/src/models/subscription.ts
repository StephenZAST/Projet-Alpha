import { MainService, AdditionalService } from "./order";
import { Timestamp } from 'firebase-admin/firestore';

export interface SubscriptionPlan {
  planId: string;
  name: string;
  price: number;
  duration: number; // in months
  servicesIncluded: MainService[];
  additionalServicesIncluded: AdditionalService[];
  itemsPerMonth: number;
  benefits: string[];
  isActive: boolean;
}

export enum SubscriptionType {
  NONE = 'NONE',
  BASIC = 'BASIC',
  PREMIUM = 'PREMIUM',
  VIP = 'VIP'
}

export interface Subscription {
  id?: string;
  type: SubscriptionType;
  startDate: Timestamp;
  endDate?: Timestamp;
  status: 'active' | 'cancelled' | 'expired';
  pricePerMonth: number;
  weightLimitPerWeek: number;
  description: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  cancellationDate?: Timestamp;
  cancellationReason?: string;
}

export interface SubscriptionUsage {
  id?: string;
  subscriptionId: string;
  userId: string;
  periodStart: Timestamp;
  periodEnd: Timestamp;
  itemsUsed: number;
  weightUsed: number;
  remainingItems: number;
  remainingWeight: number;
  lastUpdated: Timestamp;
}
