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
  SILVER = 'SILVER',    // 1001-5000 points
  GOLD = 'GOLD',       // 5001-10000 points
  PLATINUM = 'PLATINUM' // 10001+ points
}

// Example function using the updated LoyaltyTier enum
export function calculateLoyaltyTier(points: number): LoyaltyTier {
  if (points <= 1000) {
    return LoyaltyTier.BRONZE;
  } else if (points <= 5000) {
    return LoyaltyTier.SILVER;
  } else if (points <= 10000) {
    return LoyaltyTier.GOLD;
  } else {
    return LoyaltyTier.PLATINUM;
  }
}

export interface Reward {
  id: string;
  name: string;
  description: string;
  pointsCost: number;
  type: RewardType;
  value: number;
  minTier: LoyaltyTier;
  expiresAt?: Date;
  isActive: boolean;
}

export enum RewardType {
  DISCOUNT_PERCENTAGE = 'discount_percentage',
  DISCOUNT_FIXED = 'discount_fixed',
  FREE_SERVICE = 'free_service',
  GIFT = 'gift'
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
  BONUS = 'BONUS'
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
  id?: string;
  name: string;
  description: string;
  pointsPerCurrency: number; // Nombre de points gagnés par unité monétaire
  pointsExpirationMonths: number;
  tiers: LoyaltyTier[];
  isActive: boolean;
}

export interface LoyaltyTierDefinition {
  name: string;
  minimumPoints: number;
  benefits: {
    pointsMultiplier: number;
    additionalPerks: string[];
  };
}
