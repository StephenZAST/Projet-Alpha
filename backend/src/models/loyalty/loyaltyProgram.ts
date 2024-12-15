import { LoyaltyTier } from './loyaltyAccount';

export interface LoyaltyProgram {
  id: string;
  clientId: string;
  points: number;
  tier: LoyaltyTier;
  referralCode: string;          // Personal referral code
  totalReferrals: number;
  createdAt: string;
  updatedAt: string;
}
