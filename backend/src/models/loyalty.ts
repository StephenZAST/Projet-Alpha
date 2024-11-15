import { Timestamp } from 'firebase-admin/firestore';

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
  tier: LoyaltyTierEnum;
  lastUpdated: Date;
}

// Updated LoyaltyTier enum
export enum LoyaltyTierEnum {
  BRONZE = 'BRONZE',    // 0-1000 points
  SILVER = 'SILVER',    // 1001-5000 points
  GOLD = 'GOLD',       // 5001-10000 points
  PLATINUM = 'PLATINUM' // 10001+ points
}

// Example function using the updated LoyaltyTier enum
export function calculateLoyaltyTier(points: number): LoyaltyTierEnum {
  if (points <= 1000) {
    return LoyaltyTierEnum.BRONZE;
  } else if (points <= 5000) {
    return LoyaltyTierEnum.SILVER;
  } else if (points <= 10000) {
    return LoyaltyTierEnum.GOLD;
  } else {
    return LoyaltyTierEnum.PLATINUM;
  }
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

export interface LoyaltyReward {
  id?: string;
  name: string;
  description: string;
  pointsCost: number;
  value: number;
  type: LoyaltyRewardType;
  isActive: boolean;
  validFrom: Timestamp;
  validUntil: Timestamp;
  termsAndConditions: string;
  imageUrl?: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export enum LoyaltyRewardType {
  DISCOUNT = 'discount',
  FREE_SERVICE = 'free_service',
  GIFT = 'gift',
  UPGRADE = 'upgrade'
}

export interface LoyaltyProgram {
  id?: string;
  name: string;
  description: string;
  pointsPerCurrency: number;
  minimumPointsToRedeem: number;
  pointsExpirationMonths: number;
  tiers: LoyaltyTierConfig[];
  rules: LoyaltyRule[];
  isActive: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface LoyaltyTierConfig {
  id?: string;
  name: string;
  description: string;
  minimumPoints: number;
  benefits: string[];
  multiplier: number;
  icon?: string;
  tier: LoyaltyTierEnum;
}

export interface LoyaltyRule {
  id?: string;
  name: string;
  description: string;
  type: LoyaltyRuleType;
  points: number;
  conditions: string[];
  isActive: boolean;
}

export enum LoyaltyRuleType {
  SIGNUP = 'signup',
  FIRST_ORDER = 'first_order',
  REFERRAL = 'referral',
  SPECIAL_EVENT = 'special_event',
  BIRTHDAY = 'birthday'
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

export interface Reward {
  id: string;
  name: string;
  description: string;
  pointsCost: number;
  type: RewardType;
  value: number;
  isActive: boolean;
  validFrom: Timestamp;
  validUntil: Timestamp;
}
