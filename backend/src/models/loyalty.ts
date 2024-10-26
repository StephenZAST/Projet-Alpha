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
