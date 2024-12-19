import { supabase } from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';
import { OrderItem } from './order';
import { SubscriptionType } from './subscription/subscriptionPlan';
import { SubscriptionBillingInfo } from './subscription/subscriptionBilling';

export enum BillStatus {
  DRAFT = 'draft',
  PENDING = 'pending',
  PAID = 'paid',
  OVERDUE = 'overdue',
  CANCELLED = 'cancelled',
  REFUNDED = 'refunded',
  PARTIALLY_REFUNDED = 'partially_refunded'
}

export enum PaymentMethod {
  CASH = 'CASH',
  CARD = 'CARD',
  MOBILE_MONEY = 'MOBILE_MONEY',
  BANK_TRANSFER = 'BANK_TRANSFER'
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

export interface Bill {
  id?: string;
  orderId: string;
  userId: string;
  createdAt: string;
  updatedAt: string;
  dueDate: string;
  items: BillItem[];
  subtotal: number;
  tax: number;
  discount?: number;
  loyaltyPointsUsed?: number;
  loyaltyPointsEarned: number;
  total: number;
  status: BillStatus;
  subscriptionInfo?: SubscriptionBillingInfo;
  paymentMethod?: PaymentMethod;
  paymentStatus: PaymentStatus;
  paymentDate?: string;
  refundStatus?: RefundStatus;
  refundDate?: string;
  refundAmount?: number;
  notes?: string;
  currency: string; // Added currency property
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
