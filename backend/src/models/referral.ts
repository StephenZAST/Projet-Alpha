import { supabase } from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export interface Referral {
  id: string;
  referrerId: string; // ID of the user who refers
  referredId: string; // ID of the referred user
  referralCode: string;
  status: 'PENDING' | 'ACTIVE' | 'EXPIRED';
  pointsEarned: number;
  ordersCount: number;
  firstOrderCompleted: boolean;
  createdAt: string;
  activatedAt?: string;
  expiresAt?: string;
}

export interface ReferralReward {
  id: string;
  referralId: string;
  referrerId: string;
  referredId: string;
  type: 'POINTS' | 'DISCOUNT' | 'CASH';
  value: number;
  status: 'PENDING' | 'CREDITED' | 'EXPIRED';
  orderId?: string;
  createdAt: string;
  creditedAt?: string;
}

export interface ReferralProgram {
  id: string;
  name: string;
  description: string;
  referrerReward: {
    type: 'POINTS' | 'DISCOUNT' | 'CASH';
    value: number;
  };
  referredReward: {
    type: 'POINTS' | 'DISCOUNT' | 'CASH';
    value: number;
  };
  minimumOrderValue: number;
  validityPeriod: number; // in days
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}
