import { Request, Response } from 'express'; 
import { LoyaltyService } from '../services/loyalty.service';
import { LoyaltyAdminService } from '../services/loyaltyAdmin.service';

export class LoyaltyController {
  static async earnPoints(req: Request, res: Response) {
    try {
      const { points, source, referenceId } = req.body;
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await LoyaltyService.earnPoints(userId, points, source, referenceId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  } 

  static async spendPoints(req: Request, res: Response) {
    try {
      const { points, source, referenceId } = req.body;
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await LoyaltyService.spendPoints(userId, points, source, referenceId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  } 

  static async getPointsBalance(req: Request, res: Response) {
    try {
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await LoyaltyService.getPointsBalance(userId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  // Routes admin
  static async getAllLoyaltyPoints(req: Request, res: Response) {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const query = req.query.query as string;

      const result = await LoyaltyAdminService.getAllLoyaltyPoints({ page, limit, query });
      res.json({ success: true, data: result });
    } catch (error: any) {
      console.error('[LoyaltyController] Error getting all loyalty points:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

  static async getLoyaltyStats(req: Request, res: Response) {
    try {
      const result = await LoyaltyAdminService.getLoyaltyStats();
      res.json({ success: true, data: result });
    } catch (error: any) {
      console.error('[LoyaltyController] Error getting loyalty stats:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

  static async getLoyaltyPointsByUserId(req: Request, res: Response) {
    try {
      const { userId } = req.params;
      const result = await LoyaltyAdminService.getLoyaltyPointsByUserId(userId);
      res.json({ success: true, data: result });
    } catch (error: any) {
      console.error('[LoyaltyController] Error getting loyalty points by user ID:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

  static async getPointTransactions(req: Request, res: Response) {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const userId = req.query.userId as string;
      const type = req.query.type as string;
      const source = req.query.source as string;

      const result = await LoyaltyAdminService.getPointTransactions({
        page,
        limit,
        userId,
        type,
        source,
      });
      res.json({ success: true, data: result });
    } catch (error: any) {
      console.error('[LoyaltyController] Error getting point transactions:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

  static async addPointsToUser(req: Request, res: Response) {
    try {
      const { userId } = req.params;
      const { points, source, referenceId } = req.body;

      const result = await LoyaltyAdminService.addPointsToUser(userId, points, source, referenceId);
      res.json({ success: true, data: result });
    } catch (error: any) {
      console.error('[LoyaltyController] Error adding points to user:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

  static async deductPointsFromUser(req: Request, res: Response) {
    try {
      const { userId } = req.params;
      const { points, source, referenceId } = req.body;

      const result = await LoyaltyAdminService.deductPointsFromUser(userId, points, source, referenceId);
      res.json({ success: true, data: result });
    } catch (error: any) {
      console.error('[LoyaltyController] Error deducting points from user:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

  static async getUserPointHistory(req: Request, res: Response) {
    try {
      const { userId } = req.params;
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;

      const result = await LoyaltyAdminService.getUserPointHistory(userId, { page, limit });
      res.json({ success: true, data: result });
    } catch (error: any) {
      console.error('[LoyaltyController] Error getting user point history:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

  // Gestion des récompenses
  static async getAllRewards(req: Request, res: Response) {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const isActive = req.query.isActive === 'true' ? true : req.query.isActive === 'false' ? false : undefined;
      const type = req.query.type as string;

      const result = await LoyaltyAdminService.getAllRewards({ page, limit, isActive, type });
      res.json({ success: true, data: result });
    } catch (error: any) {
      console.error('[LoyaltyController] Error getting all rewards:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

  static async getRewardById(req: Request, res: Response) {
    try {
      const { rewardId } = req.params;
      const result = await LoyaltyAdminService.getRewardById(rewardId);
      res.json({ success: true, data: result });
    } catch (error: any) {
      console.error('[LoyaltyController] Error getting reward by ID:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

  static async createReward(req: Request, res: Response) {
    try {
      const rewardData = req.body;
      const result = await LoyaltyAdminService.createReward(rewardData);
      res.status(201).json({ success: true, data: result });
    } catch (error: any) {
      console.error('[LoyaltyController] Error creating reward:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

  static async updateReward(req: Request, res: Response) {
    try {
      const { rewardId } = req.params;
      const updateData = req.body;
      const result = await LoyaltyAdminService.updateReward(rewardId, updateData);
      res.json({ success: true, data: result });
    } catch (error: any) {
      console.error('[LoyaltyController] Error updating reward:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

  static async deleteReward(req: Request, res: Response) {
    try {
      const { rewardId } = req.params;
      await LoyaltyAdminService.deleteReward(rewardId);
      res.json({ success: true, message: 'Reward deleted successfully' });
    } catch (error: any) {
      console.error('[LoyaltyController] Error deleting reward:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

  // Gestion des demandes de récompenses
  static async getRewardClaims(req: Request, res: Response) {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
      const status = req.query.status as string;
      const userId = req.query.userId as string;
      const rewardId = req.query.rewardId as string;

      const result = await LoyaltyAdminService.getRewardClaims({
        page,
        limit,
        status,
        userId,
        rewardId,
      });
      res.json({ success: true, data: result });
    } catch (error: any) {
      console.error('[LoyaltyController] Error getting reward claims:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

  static async getPendingRewardClaims(req: Request, res: Response) {
    try {
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;

      const result = await LoyaltyAdminService.getPendingRewardClaims({ page, limit });
      res.json({ success: true, data: result });
    } catch (error: any) {
      console.error('[LoyaltyController] Error getting pending reward claims:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

  static async approveRewardClaim(req: Request, res: Response) {
    try {
      const { claimId } = req.params;
      await LoyaltyAdminService.approveRewardClaim(claimId);
      res.json({ success: true, message: 'Reward claim approved successfully' });
    } catch (error: any) {
      console.error('[LoyaltyController] Error approving reward claim:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

  static async rejectRewardClaim(req: Request, res: Response) {
    try {
      const { claimId } = req.params;
      const { reason } = req.body;
      await LoyaltyAdminService.rejectRewardClaim(claimId, reason);
      res.json({ success: true, message: 'Reward claim rejected successfully' });
    } catch (error: any) {
      console.error('[LoyaltyController] Error rejecting reward claim:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

  static async markRewardClaimAsUsed(req: Request, res: Response) {
    try {
      const { claimId } = req.params;
      await LoyaltyAdminService.markRewardClaimAsUsed(claimId);
      res.json({ success: true, message: 'Reward claim marked as used successfully' });
    } catch (error: any) {
      console.error('[LoyaltyController] Error marking reward claim as used:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

  // Utilitaires
  static async calculateOrderPoints(req: Request, res: Response) {
    try {
      const { orderAmount } = req.body;
      const points = Math.floor(orderAmount * 0.01); // 1 point par FCFA
      res.json({ success: true, data: { points } });
    } catch (error: any) {
      console.error('[LoyaltyController] Error calculating order points:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }

  static async processOrderPoints(req: Request, res: Response) {
    try {
      const { userId, orderId, orderAmount } = req.body;
      const points = Math.floor(orderAmount * 0.01);
      
      const result = await LoyaltyService.earnPoints(userId, points, 'ORDER', orderId);
      res.json({ success: true, data: result });
    } catch (error: any) {
      console.error('[LoyaltyController] Error processing order points:', error);
      res.status(500).json({ success: false, error: error.message });
    }
  }
}
