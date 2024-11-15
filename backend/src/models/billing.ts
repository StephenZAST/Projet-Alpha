import { Order } from './order';
import { SubscriptionType } from './subscription';
import { Timestamp } from 'firebase-admin/firestore';

export interface Bill {
  id?: string;
  orderId: string;
  userId: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  dueDate: Timestamp;
  items: BillItem[];
  subtotal: number;
  tax: number;
  discount?: number;
  loyaltyPointsUsed?: number;
  loyaltyPointsEarned: number;
  total: number;
  status: BillStatus;
  subscriptionInfo?: SubscriptionBillingInfo;
  paymentMethod?: string;
  paymentStatus: PaymentStatus;
  paymentDate?: Timestamp;
  refundStatus?: RefundStatus;
  refundDate?: Timestamp;
  refundAmount?: number;
  notes?: string;
}

export interface BillItem {
  description: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
  weight?: number;
  category: string;
  serviceType?: string;
  additionalNotes?: string;
}

export interface SubscriptionBillingInfo {
  type: SubscriptionType;
  collectionsRemaining: number;
  nextCollectionDate?: Timestamp;
  weightLimit: number;
  currentWeight: number;
  periodStart: Timestamp;
  periodEnd: Timestamp;
}

export enum BillStatus {
  DRAFT = 'draft',
  PENDING = 'pending',
  PAID = 'paid',
  OVERDUE = 'overdue',
  CANCELLED = 'cancelled',
  REFUNDED = 'refunded',
  PARTIALLY_REFUNDED = 'partially_refunded'
}

export enum PaymentStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed',
  CANCELLED = 'cancelled'
}

export enum RefundStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed',
  CANCELLED = 'cancelled'
}

export interface LoyaltyTransaction {
  id?: string;
  userId: string;
  orderId?: string;
  billId?: string;
  type: LoyaltyTransactionType;
  points: number;
  description: string;
  createdAt: Timestamp;
  expiryDate?: Timestamp;
}

export enum LoyaltyTransactionType {
  EARNED = 'earned',
  REDEEMED = 'redeemed',
  EXPIRED = 'expired',
  ADJUSTED = 'adjusted',
  CANCELLED = 'cancelled'
}

export interface Offer {
  id?: string;
  code: string;
  type: OfferType;
  value: number;
  minOrderValue?: number;
  maxDiscount?: number;
  startDate: Timestamp;
  endDate: Timestamp;
  description: string;
  termsAndConditions: string;
  applicableServices: string[];
  userType: UserOfferType[];
  isActive: boolean;
  usageLimit?: number;
  usageCount: number;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

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

export { SubscriptionType };
