import { Timestamp } from 'firebase-admin/firestore';
import { OrderItem } from './order';

export enum BillStatus {
  PENDING = 'PENDING',
  PAID = 'PAID',
  PARTIALLY_PAID = 'PARTIALLY_PAID',
  OVERDUE = 'OVERDUE',
  CANCELLED = 'CANCELLED',
  REFUNDED = 'REFUNDED',
  FAILED = 'FAILED'
}

export enum PaymentMethod {
  CASH = 'CASH',
  CREDIT_CARD = 'CREDIT_CARD',
  DEBIT_CARD = 'DEBIT_CARD',
  BANK_TRANSFER = 'BANK_TRANSFER',
  MOBILE_MONEY = 'MOBILE_MONEY',
  WALLET = 'WALLET',
  LOYALTY_POINTS = 'LOYALTY_POINTS'
}

export interface Bill {
  id?: string;
  orderId: string;
  userId: string;
  items: OrderItem[];
  subtotal: number;
  taxAmount: number;
  taxRate: number;
  deliveryFee: number;
  discount?: {
    type: 'PERCENTAGE' | 'FIXED' | 'LOYALTY',
    value: number;
    code?: string;
  };
  totalAmount: number;
  amountPaid: number;
  remainingAmount: number;
  status: BillStatus;
  dueDate: Timestamp;
  paymentMethod?: PaymentMethod;
  paymentDetails?: {
    transactionId?: string;
    paymentProvider?: string;
    cardLast4?: string;
    receiptUrl?: string;
  };
  billingAddress: {
    name: string;
    address: string;
    city: string;
    state: string;
    country: string;
    postalCode: string;
    phone: string;
    email: string;
  };
  invoiceNumber: string;
  notes?: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  paidAt?: Timestamp;
  paymentDate?: Timestamp;
  refundAmount?: number;
  paymentReference?: string;
  refundDate?: Timestamp;
  refundReason?: string;
  refundReference?: string; // Added refundReference property
}

export interface Payment {
  id?: string;
  billId: string;
  amount: number;
  method: PaymentMethod;
  status: 'PENDING' | 'SUCCESS' | 'FAILED' | 'REFUNDED';
  transactionId?: string;
  paymentProvider?: string;
  paymentDetails?: Record<string, any>;
  refundReason?: string;
  createdAt: Timestamp;
  processedAt?: Timestamp;
}

export interface BillingSummary {
  totalBills: number;
  totalAmount: number;
  paidAmount: number;
  pendingAmount: number;
  overdueAmount: number;
  averageBillAmount: number;
  paymentMethodBreakdown: {
    method: PaymentMethod;
    count: number;
    amount: number;
  }[];
  statusBreakdown: {
    status: BillStatus;
    count: number;
    amount: number;
  }[];
  period: {
    startDate: Timestamp;
    endDate: Timestamp;
  };
}

export interface Refund {
  id?: string;
  billId: string;
  paymentId: string;
  amount: number;
  reason: string;
  status: 'PENDING' | 'PROCESSED' | 'FAILED';
  processedBy?: string;
  notes?: string;
  createdAt: Timestamp;
  processedAt?: Timestamp;
}
