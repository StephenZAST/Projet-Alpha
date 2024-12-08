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
  LoyaltyProgram,
} from '../models/loyalty';
import { UserAddress, UserProfile } from '../models/user';

export class LoyaltyController {
  private loyaltyService: LoyaltyService;

  constructor() {
    this.loyaltyService = new LoyaltyService();
  }

  async createLoyaltyProgram(req: Request<{}, {}, Omit<LoyaltyProgram, 'id' | 'createdAt' | 'updatedAt'>>, res: Response, next: NextFunction) {
    try {
      const validatedLoyaltyProgram = req.body as Omit<LoyaltyProgram, 'id' | 'createdAt' | 'updatedAt'>;
      const loyaltyProgram = await this.loyaltyService.createLoyaltyProgram(validatedLoyaltyProgram);
      res.status(201).json(loyaltyProgram);
    } catch (error) {
      next(error);
    }
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
      const { userId, rewardId, shippingAddress } = req.body;
      const redemptionId = await this.loyaltyService.redeemReward(userId, rewardId, shippingAddress);
      res.status(200).json({ redemptionId });
    } catch (error) {
      next(error);
    }
  }

  async verifyAndClaimPhysicalReward(req: Request, res: Response, next: NextFunction) {
    try {
      const { redemptionId } = req.params;
      const { adminId, notes } = req.body;
      const success = await this.loyaltyService.verifyAndClaimPhysicalReward(redemptionId, adminId, notes);
      res.status(200).json({ success });
    } catch (error) {
      next(error);
    }
  }

  async getPendingPhysicalRewards(req: Request, res: Response, next: NextFunction) {
    try {
      const pendingRewards = await this.loyaltyService.getPendingPhysicalRewards();
      res.status(200).json(pendingRewards);
    } catch (error) {
      next(error);
    }
  }

  async getAvailableRewards(req: Request, res: Response, next: NextFunction) {
    try {
      const { userId } = req.params;
      const { type, category, status } = req.query;
      const rewards = await this.loyaltyService.getAvailableRewards(userId, {
        type: type as string,
        category: category as string,
        status: status as string
      });
      res.status(200).json(rewards);
    } catch (error) {
      next(error);
    }
  }

  async getPointsHistory(req: Request, res: Response, next: NextFunction) {
    try {
      const { userId } = req.params;
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const history = await this.loyaltyService.getPointsHistory(userId, page, limit);
      res.status(200).json(history);
    } catch (error) {
      next(error);
    }
  }

  async createReward(req: Request, res: Response, next: NextFunction) {
    try {
      const rewardData = req.body;
      const reward = await this.loyaltyService.createReward(rewardData);
      res.status(201).json(reward);
    } catch (error) {
      next(error);
    }
  }

  async updateReward(req: Request, res: Response, next: NextFunction) {
    try {
      const { rewardId } = req.params;
      const rewardData = req.body;
      const updatedReward = await this.loyaltyService.updateReward(rewardId, rewardData);
      res.status(200).json(updatedReward);
    } catch (error) {
      next(error);
    }
  }

  async deleteReward(req: Request, res: Response, next: NextFunction) {
    try {
      const { rewardId } = req.params;
      await this.loyaltyService.deleteReward(rewardId);
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

  async getLoyaltyProgram(req: Request, res: Response, next: NextFunction) {
    try {
      const loyaltyProgram = await this.loyaltyService.getLoyaltyProgram();
      if (!loyaltyProgram) {
        throw new AppError(404, 'Loyalty program not found', errorCodes.NOT_FOUND);
      }
      res.status(200).json(loyaltyProgram);
    } catch (error) {
      next(error);
    }
  }

  async getUserPoints(req: Request, res: Response, next: NextFunction) {
    try {
      const { userId } = req.params;
      const points = await this.loyaltyService.getUserPoints(userId);
      res.status(200).json({ points });
    } catch (error) {
      next(error);
    }
  }

  async adjustUserPoints(req: Request, res: Response, next: NextFunction) {
    try {
      const { userId, points, reason } = req.body;
      const updatedAccount = await this.loyaltyService.adjustUserPoints(userId, points, reason);
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
      const redemptions = await this.loyaltyService.getRewardRedemptions({
        page: page ? parseInt(page as string, 10) : undefined,
        limit: limit ? parseInt(limit as string, 10) : undefined,
        status: status as string | undefined,
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
      const { status, notes } = req.body;
      const updatedRedemption = await this.loyaltyService.updateRedemptionStatus(redemptionId, status, notes);
      res.status(200).json(updatedRedemption);
    } catch (error) {
      next(error);
    }
  }

  async getAllLoyaltyPrograms(req: Request, res: Response, next: NextFunction) {
    try {
      const loyaltyPrograms = await this.loyaltyService.getAllLoyaltyPrograms();
      res.status(200).json(loyaltyPrograms);
    } catch (error) {
      next(error);
    }
  }

  async getLoyaltyProgramById(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const loyaltyProgram = await this.loyaltyService.getLoyaltyProgramById(id);
      if (!loyaltyProgram) {
        throw new AppError(404, 'Loyalty program not found', errorCodes.NOT_FOUND);
      }
      res.status(200).json(loyaltyProgram);
    } catch (error) {
      next(error);
    }
  }

  async updateLoyaltyProgram(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const programData = req.body;
      const updatedProgram = await this.loyaltyService.updateLoyaltyProgram(id, programData);
      res.status(200).json(updatedProgram);
    } catch (error) {
      next(error);
    }
  }

  async deleteLoyaltyProgram(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      await this.loyaltyService.deleteLoyaltyProgram(id);
      res.status(204).send();
    } catch (error) {
      next(error);
    }
  }
}
