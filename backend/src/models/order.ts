import { Timestamp } from 'firebase-admin/firestore';

export enum OrderStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  DELIVERED = 'delivered',
  CANCELLED = 'cancelled'
}

export enum OrderType {
  STANDARD = 'standard',
  ONE_CLICK = 'one_click'
}

export enum MainService {
  LAUNDRY = 'laundry',
  DRY_CLEANING = 'dry_cleaning',
  IRONING = 'ironing'
}

export interface OrderItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
  itemType: string;
  priceType: string;
}

export interface OrderInput {
  userId: string;
  items: OrderItem[];
  totalAmount: number;
  paymentMethod: string;
  type?: OrderType;
  oneClickOrder?: boolean;
  orderNotes?: string;
}

export interface Order {
  id: string;
  userId: string;
  items: OrderItem[];
  totalAmount: number;
  status: OrderStatus;
  type: OrderType;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  deliveryAddress: string;
  deliveryInstructions: string;
  deliveryPersonId: string | null;
  deliveryTime: Timestamp | null;
  paymentMethod: string;
  paymentStatus: 'PENDING' | 'PAID' | 'FAILED' | 'REFUNDED';
  loyaltyPointsUsed: number;
  loyaltyPointsEarned: number;
  referralCode: string | null;
  oneClickOrder: boolean;
  orderNotes: string;
}
