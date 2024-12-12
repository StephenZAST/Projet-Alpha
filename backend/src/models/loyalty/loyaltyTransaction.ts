import { Timestamp } from 'firebase-admin/firestore';

export enum LoyaltyTransactionType {
  EARNED = 'earned',
  REDEEMED = 'redeemed',
  EXPIRED = 'expired',
  ADJUSTED = 'adjusted',
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
  createdAt: string;
  expiryDate?: string;
}
