import { MainService, AdditionalService } from './order';
import { Timestamp } from 'firebase-admin/firestore';

export interface SubscriptionPlan {
  id?: string;
  name: string;
  description: string;
  type: SubscriptionType;
  price: number;
  duration: number; // in months
  servicesIncluded: MainService[];
  additionalServicesIncluded: AdditionalService[];
  itemsPerMonth: number;
  weightLimitPerWeek: number;
  benefits: string[];
  isActive: boolean;
  discountPercentage?: number;
  minimumCommitment?: number; // in months
  earlyTerminationFee?: number;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export enum SubscriptionType {
  NONE = 'NONE',
  BASIC = 'BASIC',
  PREMIUM = 'PREMIUM',
  VIP = 'VIP'
}

export interface Subscription {
  id?: string;
  userId: string;
  planId: string;
  type: SubscriptionType;
  startDate: Timestamp;
  endDate?: Timestamp;
  status: SubscriptionStatus;
  pricePerMonth: number;
  weightLimitPerWeek: number;
  description: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  cancellationDate?: Timestamp;
  cancellationReason?: string;
  autoRenew: boolean;
  paymentMethod?: string;
  lastBillingDate?: Timestamp;
  nextBillingDate?: Timestamp;
  pauseHistory?: SubscriptionPause[];
  billingHistory?: SubscriptionBilling[];
  usageHistory?: SubscriptionUsageSnapshot[];
  currentPeriodStart?: Timestamp;
  currentPeriodEnd?: Timestamp;
  trialEnd?: Timestamp;
  discount?: {
    percentage: number;
    endDate: Timestamp;
    reason: string;
  };
}

export enum SubscriptionStatus {
  ACTIVE = 'active',
  CANCELLED = 'cancelled',
  EXPIRED = 'expired',
  SUSPENDED = 'suspended',
  PENDING = 'pending',
  PAUSED = 'paused',
  TRIAL = 'trial'
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
  servicesUsed: {
    mainServices: { [key: string]: number };
    additionalServices: { [key: string]: number };
  };
  overageCharges?: number;
  notifications?: SubscriptionNotification[];
}

export interface SubscriptionPause {
  startDate: Timestamp;
  endDate?: Timestamp;
  reason: string;
  requestedBy: string;
  status: 'active' | 'scheduled' | 'completed' | 'cancelled';
}

export interface SubscriptionBilling {
  date: Timestamp;
  amount: number;
  status: 'pending' | 'successful' | 'failed';
  paymentMethod: string;
  invoiceUrl?: string;
  failureReason?: string;
}

export interface SubscriptionUsageSnapshot {
  date: Timestamp;
  itemsUsed: number;
  weightUsed: number;
  overageCharges: number;
}

export interface SubscriptionNotification {
  type: 'usage_warning' | 'payment_due' | 'renewal_reminder' | 'expiration_warning';
  message: string;
  date: Timestamp;
  isRead: boolean;
  actionRequired: boolean;
}
