import { Order } from './order';
import { SubscriptionType } from './user';

export interface Bill {
  id: string;
  orderId: string;
  userId: string;
  createdAt: Date;
  dueDate: Date;
  items: BillItem[];
  subtotal: number;
  tax: number;
  discount?: number;
  loyaltyPointsUsed?: number;
  loyaltyPointsEarned: number;
  total: number;
  status: BillStatus;
  subscriptionInfo?: SubscriptionBillingInfo;
}

export interface BillItem {
  description: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
  weight?: number;
  category: string;
}

export interface SubscriptionBillingInfo {
  type: SubscriptionType;
  collectionsRemaining: number;
  nextCollectionDate?: Date;
  weightLimit: number;
  currentWeight: number;
}

export enum BillStatus {
  PENDING = 'pending',
  PAID = 'paid',
  OVERDUE = 'overdue',
  CANCELLED = 'cancelled'
}

export interface LoyaltyTransaction {
  id: string;
  userId: string;
  orderId?: string;
  type: LoyaltyTransactionType;
  points: number;
  description: string;
  createdAt: Date;
  expiryDate?: Date;
}

export enum LoyaltyTransactionType {
  EARNED = 'earned',
  REDEEMED = 'redeemed',
  EXPIRED = 'expired',
  BONUS = 'bonus'
}

export interface Offer {
  id: string;
  code: string;
  type: OfferType;
  value: number; // Pourcentage ou montant fixe
  minOrderValue?: number;
  maxDiscount?: number;
  startDate: Date;
  endDate: Date;
  description: string;
  termsAndConditions: string;
  applicableServices: string[];
  userType: UserOfferType[];
}

export enum OfferType {
  PERCENTAGE = 'percentage',
  FIXED_AMOUNT = 'fixed_amount',
  FREE_SERVICE = 'free_service'
}

export enum UserOfferType {
  ALL = 'all',
  NEW_USER = 'new_user',
  SUBSCRIPTION = 'subscription',
  LOYALTY = 'loyalty'
}

export { SubscriptionType };
