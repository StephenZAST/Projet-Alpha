import { MainService, AdditionalService } from '../models/order';

export enum SubscriptionStatus {
  ACTIVE = 'active',
  CANCELLED = 'cancelled',
  EXPIRED = 'expired',
  SUSPENDED = 'suspended',
  PENDING = 'pending',
  PAUSED = 'paused',
  TRIAL = 'trial'
}

export enum SubscriptionType {
  NONE = 'NONE',
  BASIC = 'BASIC',
  PREMIUM = 'PREMIUM',
  VIP = 'VIP'
}

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
  createdAt: string;
  updatedAt: string;
}

export interface SubscriptionPause {
  startDate: string;
  endDate?: string;
  reason: string;
  requestedBy: string;
  status: 'active' | 'scheduled' | 'completed' | 'cancelled';
}

export interface SubscriptionBilling {
  date: string;
  amount: number;
  status: 'pending' | 'successful' | 'failed';
  paymentMethod: string;
  invoiceUrl?: string;
  failureReason?: string;
}

export interface SubscriptionUsage {
  id?: string;
  subscriptionId: string;
  userId: string;
  periodStart: string;
  periodEnd: string;
  itemsUsed: number;
  weightUsed: number;
  remainingItems: number;
  remainingWeight: number;
  lastUpdated: string;
  servicesUsed: {
    mainServices: { [key: string]: number };
    additionalServices: { [key: string]: number };
  };
  overageCharges?: number;
  notifications?: SubscriptionNotification[];
}

export interface SubscriptionNotification {
  type: 'usage_warning' | 'payment_due' | 'renewal_reminder' | 'expiration_warning';
  message: string;
  date: string;
  isRead: boolean;
  actionRequired: boolean;
}

export interface SubscriptionUsageSnapshot {
  date: string;
  itemsUsed: number;
  weightUsed: number;
  overageCharges: number;
}

export interface Subscription {
  id?: string;
  userId: string;
  planId: string;
  type: SubscriptionType;
  startDate: string;
  endDate?: string;
  status: SubscriptionStatus;
  pricePerMonth: number;
  weightLimitPerWeek: number;
  description: string;
  createdAt: string;
  updatedAt: string;
  cancellationDate?: string;
  cancellationReason?: string;
  autoRenew: boolean;
  paymentMethod?: string;
  lastBillingDate?: string;
  nextBillingDate?: string;
  pauseHistory?: SubscriptionPause[];
  billingHistory?: SubscriptionBilling[];
  usageHistory?: SubscriptionUsageSnapshot[];
  currentPeriodStart?: string;
  currentPeriodEnd?: string;
  trialEnd?: string;
  discount?: {
    percentage: number;
    endDate: string;
    reason: string;
  };
}
