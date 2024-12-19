import { createClient } from '@supabase/supabase-js';
import { Referral, ReferralReward, ReferralProgram } from '../models/referral';
import { CodeGenerator } from '../utils/codeGenerator'; // Correct import
import { AppError, errorCodes } from '../utils/errors'; // Import errorCodes
import { notificationService } from './notifications'; // Correct import
import { getReferral, createReferral, updateReferral, deleteReferral } from './referral/referralManagement';
import { getReferralReward, createReferralReward, updateReferralReward, deleteReferralReward } from './referral/rewardManagement';
import { getActiveReferralProgram } from './referral/programManagement';
import { referral } from './notification/referral';

import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

const referralsTable = 'referrals';
const rewardsTable = 'referral-rewards';
const programsTable = 'referral-programs';

export class ReferralService {
  private referralsRef = supabase.from(referralsTable);
  private rewardsRef = supabase.from(rewardsTable);
  private programsRef = supabase.from(programsTable);

  constructor() {
  }

  /**
   * Create a new referral
   */
  async createReferral(referrerId: string, referredEmail: string): Promise<Referral> {
    try {
      // Check if the email has already been referred
      const existingReferral = await getReferral(referredEmail);

      if (existingReferral) {
        throw new AppError(400, 'This email has already been referred', errorCodes.REFERRAL_ALREADY_EXISTS);
      }

      const referralData: Omit<Referral, 'id'> = {
        referrerId,
        referredId: '', // Will be updated upon registration
        referralCode: await CodeGenerator.generateAffiliateCode(), // Assuming generateAffiliateCode is the correct function
        status: 'PENDING',
        pointsEarned: 0,
        ordersCount: 0,
        firstOrderCompleted: false,
        createdAt: new Date().toISOString()
      };

      const newReferral = await createReferral(referralData);

      // Send invitation email
      await referral.sendReferralInvitation(referredEmail, newReferral.referralCode);

      return newReferral;
    } catch (error) {
      console.error('Error creating referral:', error);
      throw error;
    }
  }

  /**
   * Activate a referral
   */
  async activateReferral(referralCode: string, referredId: string): Promise<void> {
    try {
      const referral = await getReferral(referralCode);

      if (!referral || referral.status !== 'PENDING') {
        throw new AppError(404, 'Invalid or expired referral code', errorCodes.INVALID_REFERRAL_CODE);
      }

      // Activate the referral
      await updateReferral(referral.id, {
        referredId,
        status: 'ACTIVE',
        activatedAt: new Date().toISOString(),
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString() // 30 days
      });

      // Create initial rewards
      await this.createInitialRewards(referral.id, referral.referrerId, referredId);
    } catch (error) {
      console.error('Error activating referral:', error);
      throw error;
    }
  }

  private async createInitialRewards(
    referralId: string,
    referrerId: string,
    referredId: string
  ): Promise<void> {
    try {
      const program = await this.getActiveProgram();

      // Reward for the referrer
      const referrerRewardData: Omit<ReferralReward, 'id'> = {
        referralId,
        referrerId,
        referredId,
        type: program.referrerReward.type,
        value: program.referrerReward.value,
        status: 'PENDING',
        createdAt: new Date().toISOString()
      };

      // Reward for the referred
      const referredRewardData: Omit<ReferralReward, 'id'> = {
        referralId,
        referrerId,
        referredId,
        type: program.referredReward.type,
        value: program.referredReward.value,
        status: 'PENDING',
        createdAt: new Date().toISOString()
      };

      await Promise.all([
        createReferralReward(referrerRewardData),
        createReferralReward(referredRewardData)
      ]);
    } catch (error) {
      console.error('Error creating initial rewards:', error);
      throw error;
    }
  }

  /**
   * Process first order reward
   */
  async processFirstOrderReward(referralId: string, orderId: string): Promise<void> {
    try {
      const referral = await getReferral(referralId);

      if (!referral) {
        throw new AppError(404, 'Referral not found', errorCodes.REFERRAL_NOT_FOUND);
      }

      if (referral.firstOrderCompleted) {
        throw new AppError(400, 'First order reward already processed', errorCodes.REWARD_ALREADY_PROCESSED);
      }

      // Update rewards
      const rewards = await this.rewardsRef
        .select('*')
        .eq('referralId', referralId)
        .eq('status', 'PENDING');

      const updatePromises = rewards.data ? rewards.data.map((reward: ReferralReward) => {
        return updateReferralReward(reward.id, {
          status: 'CREDITED',
          orderId,
          creditedAt: new Date().toISOString()
        });
      }) : [];

      await Promise.all(updatePromises);

      // Update referral
      await updateReferral(referralId, {
        firstOrderCompleted: true,
        ordersCount: 1,
      });
    } catch (error) {
      console.error('Error processing first order reward:', error);
      throw error;
    }
  }

  /**
   * Get active referral program
   */
  private async getActiveProgram(): Promise<ReferralProgram> {
    try {
      const program = await getActiveReferralProgram();

      if (!program) {
        throw new AppError(404, 'No active referral program found', errorCodes.NO_ACTIVE_PROGRAM);
      }

      return program;
    } catch (error) {
      console.error('Error getting active referral program:', error);
      throw error;
    }
  }

  /**
   * Get referral stats
   */
  async getReferralStats(userId: string): Promise<{
    totalReferrals: number;
    activeReferrals: number;
    completedReferrals: number;
    totalRewards: number;
  }> {
    try {
      const referrals = await this.referralsRef
        .select('*')
        .eq('referrerId', userId);

      const referralStats = referrals.data ? referrals.data.map((referral: Referral) => ({
        ...referral,
        id: referral.id
      })) : [];

      return {
        totalReferrals: referralStats.length,
        activeReferrals: referralStats.filter(r => r.status === 'ACTIVE').length,
        completedReferrals: referralStats.filter(r => r.firstOrderCompleted).length,
        totalRewards: 0 // To be calculated based on credited rewards
      };
    } catch (error) {
      console.error('Error getting referral stats:', error);
      throw error;
    }
  }
}

export const referralService = new ReferralService();
