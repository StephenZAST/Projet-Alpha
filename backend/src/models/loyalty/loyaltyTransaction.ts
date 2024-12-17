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
  rewardId?: string; // Added rewardId property
  redemptionId?: string; // Added redemptionId property
  type: LoyaltyTransactionType;
  points: number;
  description: string;
  createdAt: string;
  expiryDate?: string;
}
