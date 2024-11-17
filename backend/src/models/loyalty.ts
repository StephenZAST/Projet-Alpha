// Add new interface for reward redemptions
export interface RewardRedemption {
  id: string;
  userId: string;
  rewardId: string;
  redemptionDate: Date;
  status: RewardStatus;
  claimedDate?: Date;
  claimedByAdminId?: string;
  verificationCode: string;
  notes?: string;
}

export interface LoyaltyAccount {
  userId: string;
  points: number;
  lifetimePoints: number;
  tier: LoyaltyTier;
  lastUpdated: Date;
}

// Updated LoyaltyTier enum
export enum LoyaltyTier {
  BRONZE = 'BRONZE',    // 0-1000 points
  SILVER = 'SILVER',     // 1001-5000 points
  GOLD = 'GOLD',
  PLATINUM = 'PLATINUM'
}

// Example function using the updated LoyaltyTier enum
function calculateLoyaltyTier(points: number): LoyaltyTier {
  if (points <= 1000) {
    return LoyaltyTier.BRONZE;
  } else if (points <= 5000) {
    return LoyaltyTier.SILVER;
  }
  // Expand with more tiers if needed
  throw new Error("Points exceed defined tiers");
}

export interface Reward {
  id: string;
  clientId: string;
  type: RewardType;
  value: number;                // Points ou pourcentage de réduction
  source: 'REFERRAL' | 'PURCHASE' | 'PROMOTION';
  description: string;
  expiresAt?: Timestamp;
  status: 'ACTIVE' | 'USED' | 'EXPIRED';
  createdAt: Timestamp;
  usedAt?: Timestamp;
}

export enum RewardType {
  POINTS = 'POINTS',
  DISCOUNT = 'DISCOUNT',
  GIFT = 'GIFT'
}

// Add new status for rewards
export enum RewardStatus {
  AVAILABLE = 'available',
  REDEEMED = 'redeemed',
  CLAIMED = 'claimed',
  EXPIRED = 'expired'
}

import { Timestamp } from 'firebase-admin/firestore';

export enum LoyaltyTransactionType {
  EARNED = 'EARNED',
  REDEEMED = 'REDEEMED',
  EXPIRED = 'EXPIRED',
  BONUS = 'BONUS',
  ADJUSTED = "ADJUSTED"
}

export interface LoyaltyTransaction {
  id?: string;
  userId: string;
  type: LoyaltyTransactionType;
  points: number;
  orderId?: string;
  rewardId?: string;
  description: string;
  createdAt: Timestamp;
  expiresAt?: Timestamp;
}

export interface LoyaltyReward {
  id?: string;
  name: string;
  description: string;
  pointsCost: number;
  type: 'discount' | 'freeService' | 'gift';
  value: number; // Pourcentage de réduction ou valeur monétaire
  minOrderAmount?: number;
  maxDiscount?: number;
  validFrom: Timestamp;
  validUntil: Timestamp;
  isActive: boolean;
  termsAndConditions?: string;
  limitPerUser?: number;
  totalLimit?: number;
  redemptionCount: number;
}

export interface LoyaltyProgram {
  id: string;
  clientId: string;
  points: number;
  tier: LoyaltyTier;
  referralCode: string;          // Code de parrainage personnel
  totalReferrals: number;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface ClientReferral {
  id: string;
  referrerId: string;           // Client qui parraine
  referredId: string;           // Nouveau client parrainé
  referralCode: string;
  status: 'PENDING' | 'COMPLETED';
  createdAt: Timestamp;
  completedAt?: Timestamp;
}

export interface LoyaltyTierDefinition {
  name: string;
  minimumPoints: number;
  benefits: {
    pointsMultiplier: number;
    additionalPerks: string[];
  };
}
