import { Request, Response, NextFunction } from 'express';
import { loyaltyService } from '../services/loyalty';
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
  RewardRedemptionStatus,
} from '../models/loyalty';
import { UserProfile } from '../models/user';

export class LoyaltyController {
  async getLoyaltyAccount(req: Request, res: Response, next: NextFunction) {
    try {
      const { userId } = req.params;
      const loyaltyAccount = await loyaltyService.getLoyaltyAccount(userId);
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
      const updatedAccount = await loyaltyService.addPoints(userId, points, reason);
      res.status(200).json(updatedAccount);
    } catch (error) {
      next(error);
    }
  }

  async redeemReward(req: Request, res: Response, next: NextFunction) {
    try {
      const { userId, rewardId } = req.body;
      const redemption = await loyaltyService.redeemReward(userId, rewardId);
      res.status(200).json({ redemptionId: redemption.id });
    } catch (error) {
      next(error);
    }
  }

  async verifyAndClaimPhysicalReward(
    req: Request,
    res: Response,
    next: NextFunction
  ) {
    try {
      const { redemptionId } = req.params;
      const { notes } = req.body;
      const updatedRedemption = await loyaltyService.updateRewardRedemption(
        redemptionId,
        { status: RewardRedemptionStatus.CLAIMED, notes: notes }
      );

      res.status(200).json({ success: true, updatedRedemption });
    } catch (error) {
      next(error);
    }
  }

  async getPendingPhysicalRewards(
    req: Request,
    res: Response,
    next: NextFunction
  ) {
    try {
      const pendingRewards = await loyaltyService.getRewardRedemptions({
        status: RewardRedemptionStatus.PENDING,
      });
      res.status(200).json(pendingRewards);
    } catch (error) {
      next(error);
    }
  }

  async getAvailableRewards(req: Request, res: Response, next: NextFunction) {
    try {
      const { userId } = req.params;
      const rewards = await loyaltyService.getRewards({});
      res.status(200).json(rewards);
    } catch (error) {
      next(error);
    }
  }

  async getPointsHistory(req: Request, res: Response, next: NextFunction) {
    try {
      const { userId } = req.params;
      const history = await loyaltyService.getLoyaltyTransaction(userId);
      res.status(200).json(history);
    } catch (error) {
      next(error);
    }
  }

  async createReward(req: Request, res: Response, next: NextFunction) {
    try {
      const rewardData = req.body;
      const reward = await loyaltyService.createLoyaltyReward(rewardData);
      res.status(201).json(reward);
    } catch (error) {
      next(error);
    }
  }

  async updateReward(req: Request, res: Response, next: NextFunction) {
    try {
      const { rewardId } = req.params;
      const rewardData = req.body;
      const updatedReward = await loyaltyService.updateLoyaltyReward(
        rewardId,
        rewardData
      );
      res.status(200).json(updatedReward);
    } catch (error) {
      next(error);
    }
  }

  async deleteReward(req: Request, res: Response, next: NextFunction) {
    try {
      const { rewardId } = req.params;
      await loyaltyService.deleteLoyaltyReward(rewardId);
      res.status(204).send();
    } catch (error) {
      next(error);
    }
  }

  async getRewards(req: Request, res: Response, next: NextFunction) {
    try {
      const { page, limit, status, startDate, endDate } = req.query;
      const rewards = await loyaltyService.getRewards({
        page: page ? parseInt(page as string, 10) : undefined,
        limit: limit ? parseInt(limit as string, 10) : undefined,
        status: status as string | undefined,
        startDate: startDate ? new Date(startDate as string) : undefined,
        endDate: endDate ? new Date(endDate as string) : undefined,
      });
      res.status(200).json(rewards);
    } catch (error) {
      next(error);
    }
  }

  async getRewardById(req: Request, res: Response, next: NextFunction) {
    try {
      const { rewardId } = req.params;
      const reward = await loyaltyService.getRewardById(rewardId);
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
      const loyaltyAccount = await loyaltyService.getLoyaltyAccount(userId);
      res.status(200).json({ points: loyaltyAccount?.points || 0 });
    } catch (error) {
      next(error);
    }
  }

  async adjustUserPoints(req: Request, res: Response, next: NextFunction) {
    try {
      const { userId, points, reason } = req.body;
      const updatedAccount = await loyaltyService.addPoints(
        userId,
        points,
        reason
      );
      res.status(200).json(updatedAccount);
    } catch (error) {
      next(error);
    }
  }

  async updateLoyaltyTier(req: Request, res: Response, next: NextFunction) {
    try {
      const { tierId } = req.params;
      const tierData = req.body;
      const updatedTier = await loyaltyService.updateLoyaltyTier(
        tierId,
        tierData
      );
      res.status(200).json(updatedTier);
    } catch (error) {
      next(error);
    }
  }

  async getLoyaltyTiers(req: Request, res: Response, next: NextFunction) {
    try {
      const tiers = await loyaltyService.getLoyaltyTiers();
      res.status(200).json(tiers);
    } catch (error) {
      next(error);
    }
  }

  async getRewardRedemptions(req: Request, res: Response, next: NextFunction) {
    try {
      const { page, limit, status, startDate, endDate } = req.query;

      const queryOptions: {
        page?: number;
        limit?: number;
        status: RewardRedemptionStatus;
        startDate?: Date;
        endDate?: Date;
      } = {
        status: RewardRedemptionStatus.PENDING
      };

      if (status && Object.values(RewardRedemptionStatus).includes(status as RewardRedemptionStatus)) {
        queryOptions.status = status as RewardRedemptionStatus;
      }
      if (startDate) {
        queryOptions.startDate = new Date(startDate as string);
      }
      if (endDate) {
        queryOptions.endDate = new Date(endDate as string);
      }
      if (page) {
        queryOptions.page = parseInt(page as string, 10);
      }
      if (limit) {
        queryOptions.limit = parseInt(limit as string, 10);
      }

      const redemptions = await loyaltyService.getRewardRedemptions(
        queryOptions
      );
      res.status(200).json(redemptions);
    } catch (error) {
      next(error);
    }
  }  async updateRedemptionStatus(
    req: Request,
    res: Response,
    next: NextFunction
  ) {
    try {
      const { redemptionId } = req.params;
      const { status, notes } = req.body;

      if (
        !Object.values(RewardRedemptionStatus).includes(
          status as RewardRedemptionStatus
        )
      ) {
        return next(
          new AppError(400, 'Invalid status provided', errorCodes.VALIDATION_ERROR)
        );
      }

      const updatedRedemption = await loyaltyService.updateRewardRedemption(
        redemptionId,
        { status, notes }
      );

      res.status(200).json({ success: true, updatedRedemption });
    } catch (error) {
      next(error);
    }
  }

  async getLoyaltyProgram(req: Request, res: Response, next: NextFunction) {
    try {
      const loyaltyProgram = await loyaltyService.getLoyaltyProgram();
      if (!loyaltyProgram) {
        throw new AppError(
          404,
          'Loyalty program not found',
          errorCodes.NOT_FOUND
        );
      }
      res.status(200).json(loyaltyProgram);
    } catch (error) {
      next(error);
    }
  }

  async updateLoyaltyProgram(req: Request, res: Response, next: NextFunction) {
    try {
      const programData = req.body;
      const updatedProgram = await loyaltyService.updateLoyaltyProgram(
        '1',
        programData
      );
      res.status(200).json(updatedProgram);
    } catch (error) {
      next(error);
    }
  }
}

export const loyaltyController = new LoyaltyController();
