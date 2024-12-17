import { Request, Response, NextFunction } from 'express';
import { LoyaltyService } from '../services/loyalty';
import { AppError, errorCodes } from '../utils/errors';
import {
  LoyaltyAccount,
  LoyaltyTier,
  Reward,
  RewardRedemption,
  RewardStatus,
  RewardType,
  PointsTransaction,
  LoyaltyTierConfig,
  LoyaltyReward,
  RewardRedemptionStatus
} from '../models/loyalty';
import { UserAddress, UserProfile } from '../models/user';
import { LoyaltyProgramController } from './loyaltyController/loyaltyProgramController';
import { updateRewardRedemption, getRewardRedemptions } from '../services/loyalty/redemptions';

export class LoyaltyController {
  private loyaltyService: LoyaltyService;
  private loyaltyProgramController: LoyaltyProgramController;

  constructor() {
    this.loyaltyService = new LoyaltyService();
    this.loyaltyProgramController = new LoyaltyProgramController();
  }


  async getLoyaltyAccount(req: Request, res: Response, next: NextFunction) {
    try {
      const { userId } = req.params;
      const loyaltyAccount = await this.loyaltyService.getLoyaltyAccount(userId);
      if (!loyaltyAccount) {
        throw new AppError(404, 'Loyalty account not found', errorCodes.NOT_FOUND);
      }
      res.status(200).json(loyaltyAccount);
    } catch (error) {
      next(error);
    }
  }

  async addPoints(req: Request, res: Response, next: NextFunction) {
    try {
      const { userId, points, reason } = req.body;
      const updatedAccount = await this.loyaltyService.addPoints(userId, points, reason);
      res.status(200).json(updatedAccount);
    } catch (error) {
      next(error);
    }
  }

  async redeemReward(req: Request, res: Response, next: NextFunction) {
    try {
      const { userId, rewardId } = req.body;
      const redemptionId = await this.loyaltyService.redeemReward(userId, rewardId);
      res.status(200).json({ redemptionId });
    } catch (error) {
      next(error);
    }
  }

    async verifyAndClaimPhysicalReward(req: Request, res: Response, next: NextFunction) {
        try {
            const { redemptionId } = req.params;
            const { notes } = req.body;
            const updatedRedemption = await updateRewardRedemption(redemptionId, { status: RewardRedemptionStatus.CLAIMED, notes: notes });
            res.status(200).json({ success: !!updatedRedemption });
        } catch (error) {
            next(error);
        }
    }

    async getPendingPhysicalRewards(req: Request, res: Response, next: NextFunction) {
        try {
            const pendingRewards = await getRewardRedemptions({ status: RewardRedemptionStatus.PENDING });
            res.status(200).json(pendingRewards);
        } catch (error) {
            next(error);
        }
    }


  async getAvailableRewards(req: Request, res: Response, next: NextFunction) {
    try {
      const { userId } = req.params;
        const rewards = await this.loyaltyService.getRewards({});
      res.status(200).json(rewards);
    } catch (error) {
      next(error);
    }
  }

    async getPointsHistory(req: Request, res: Response, next: NextFunction) {
        try {
            const { userId } = req.params;
            // Assuming this logic is handled within the service
            const history = await this.loyaltyService.getLoyaltyTransaction(userId);
            res.status(200).json(history);
        } catch (error) {
            next(error);
        }
    }


  async createReward(req: Request, res: Response, next: NextFunction) {
    try {
      const rewardData = req.body;
      const reward = await this.loyaltyService.createLoyaltyReward(rewardData);
      res.status(201).json(reward);
    } catch (error) {
      next(error);
    }
  }

  async updateReward(req: Request, res: Response, next: NextFunction) {
    try {
      const { rewardId } = req.params;
      const rewardData = req.body;
      const updatedReward = await this.loyaltyService.updateLoyaltyReward(rewardId, rewardData);
      res.status(200).json(updatedReward);
    } catch (error) {
      next(error);
    }
  }

  async deleteReward(req: Request, res: Response, next: NextFunction) {
    try {
      const { rewardId } = req.params;
      await this.loyaltyService.deleteLoyaltyReward(rewardId);
      res.status(204).send();
    } catch (error) {
      next(error);
    }
  }

  async getRewards(req: Request, res: Response, next: NextFunction) {
    try {
      const { page, limit, status, startDate, endDate } = req.query;
      const rewards = await this.loyaltyService.getRewards({
        page: page ? parseInt(page as string, 10) : undefined,
        limit: limit ? parseInt(limit as string, 10) : undefined,
        status: status as string | undefined,
        startDate: startDate ? new Date(startDate as string) : undefined,
        endDate: endDate ? new Date(endDate as string) : undefined
      });
      res.status(200).json(rewards);
    } catch (error) {
      next(error);
    }
  }

  async getRewardById(req: Request, res: Response, next: NextFunction) {
    try {
      const { rewardId } = req.params;
      const reward = await this.loyaltyService.getRewardById(rewardId);
      if (!reward) {
        throw new AppError(404, 'Reward not found', errorCodes.NOT_FOUND);
      }
      res.status(200).json(reward);
    } catch (error) {
      next(error);
    }
  }


    async getUserPoints(req: Request, res: Response, next: NextFunction) {
        try {
            const { userId } = req.params;
            const loyaltyAccount = await this.loyaltyService.getLoyaltyAccount(userId);
            res.status(200).json({ points: loyaltyAccount?.points || 0 });
        } catch (error) {
            next(error);
        }
    }

    async adjustUserPoints(req: Request, res: Response, next: NextFunction) {
        try {
            const { userId, points, reason } = req.body;
            const updatedAccount = await this.loyaltyService.addPoints(userId, points, reason);
            res.status(200).json(updatedAccount);
        } catch (error) {
            next(error);
        }
    }


  async updateLoyaltyTier(req: Request, res: Response, next: NextFunction) {
    try {
      const { tierId } = req.params;
      const tierData = req.body;
      const updatedTier = await this.loyaltyService.updateLoyaltyTier(tierId, tierData);
      res.status(200).json(updatedTier);
    } catch (error) {
      next(error);
    }
  }

  async getLoyaltyTiers(req: Request, res: Response, next: NextFunction) {
    try {
      const tiers = await this.loyaltyService.getLoyaltyTiers();
      res.status(200).json(tiers);
    } catch (error) {
      next(error);
    }
  }

    async getRewardRedemptions(req: Request, res: Response, next: NextFunction) {
        try {
            const { page, limit, status, startDate, endDate } = req.query;
            const redemptions = await getRewardRedemptions({
                page: page ? parseInt(page as string, 10) : undefined,
                limit: limit ? parseInt(limit as string, 10) : undefined,
                status: status as RewardRedemptionStatus | undefined,
                startDate: startDate ? new Date(startDate as string) : undefined,
                endDate: endDate ? new Date(endDate as string) : undefined
            });
            res.status(200).json(redemptions);
        } catch (error) {
            next(error);
        }
    }


    async updateRedemptionStatus(req: Request, res: Response, next: NextFunction) {
        try {
            const { redemptionId } = req.params;
            const { status } = req.body;
            const updatedRedemption = await updateRewardRedemption(redemptionId, { status: status });
            res.status(200).json({ success: !!updatedRedemption });
        } catch (error) {
            next(error);
        }
    }
}
