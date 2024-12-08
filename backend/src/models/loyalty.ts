// Add new interface for reward redemptions
export interface RewardRedemption {
  id: string;
  userId: string;
  rewardId: string;
  redemptionDate: Date;
  status: RewardStatus;
  verificationCode: string;
  shippingAddress?: {
    street: string;
    city: string;
    state: string;
    zipCode: string;
    country: string;
    phoneNumber: string;
  };
  claimedDate?: Date;
  claimedByAdminId?: string;
  notes?: string;
  updatedAt?: Date;
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

export interface PointsTransaction {
  id: string;
  userId: string;
  amount: number;
  type: 'EARNED' | 'REDEEMED' | 'EXPIRED' | 'ADJUSTED';
  source: 'PURCHASE' | 'REFERRAL' | 'PROMOTION' | 'MANUAL' | 'SYSTEM';
  description: string;
  metadata?: {
    orderId?: string;
    promotionId?: string;
    referralId?: string;
    adminId?: string;
  };
  timestamp: Date;
}

export interface LoyaltyTierConfig {
  id: string;
  name: string;
  description: string;
  pointsThreshold: number;
  benefits: TierBenefit[];
  icon?: string;
  color?: string;
  status: 'active' | 'inactive';
  createdAt: Date;
  updatedAt: Date;
}

export interface TierBenefit {
  type: 'discount' | 'freeShipping' | 'pointsMultiplier' | 'exclusiveAccess';
  value: number | boolean;
  description: string;
}

export interface Reward {
  id: string;
  name: string;
  description: string;
  type: 'physical' | 'digital' | 'discount';
  category: string;
  pointsCost: number;
  quantity: number;
  startDate: Date;
  endDate?: Date;
  tier?: LoyaltyTier;
  metadata: {
    discountPercentage?: number;
    digitalCode?: string;
    shippingWeight?: number;
  };
  discountAmount?: number; // Added discountAmount property
  pointsRequired?: number; // Added pointsRequired property
  isActive: boolean;
  redemptionCount: number;
  createdAt: Date;
  updatedAt?: Date;
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

import { Timestamp } from 'firebase-admin/firestore';

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
