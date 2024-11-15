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

export enum LoyaltyTier {
  BRONZE = 'bronze',    // 0-1000 points
  SILVER = 'silver',    // 1001-5000 points
  GOLD = 'gold',        // 5001-10000 points
  PLATINUM = 'platinum' // 10001+ points
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

export interface LoyaltyTier {
  name: string;
  minimumPoints: number;
  benefits: {
    pointsMultiplier: number;
    additionalPerks: string[];
  };
}
