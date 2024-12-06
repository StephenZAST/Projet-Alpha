import express from 'express';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { validateRequest } from '../middleware/validateRequest';
import { loyaltyValidation } from '../validation/loyalty';
import { LoyaltyService } from '../services/loyalty'; // Correct import

const router = express.Router();
const loyaltyService = new LoyaltyService(); // Create instance

router.get('/account', isAuthenticated, async (req, res, next) => {
  try {
    const userId = req.user!.uid;
    const account = await loyaltyService.getLoyaltyAccount(userId);
    res.json(account);
  } catch (error) {
    next(error);
  }
});

router.get('/points/history', isAuthenticated, async (req, res, next) => {
  try {
    const userId = req.user!.uid;
    const { page = 1, limit = 10 } = req.query;
    const history = await loyaltyService.getPointsHistory(
      userId,
      Number(page),
      Number(limit)
    );
    res.json(history);
  } catch (error) {
    next(error);
  }
});

router.get('/rewards', isAuthenticated, async (req, res, next) => {
  try {
    const userId = req.user!.uid;
    const { type, category, status } = req.query;
    const rewards = await loyaltyService.getAvailableRewards(userId, {
      type: type as string,
      category: category as string,
      status: status as string
    });
    res.json(rewards);
  } catch (error) {
    next(error);
  }
});

router.post('/rewards/:rewardId/redeem', 
  isAuthenticated, 
  validateRequest(loyaltyValidation.redeemRewardSchema),
  async (req, res, next) => {
    try {
      const userId = req.user!.uid;
      const { shippingAddress } = req.body;
      const redemption = await loyaltyService.redeemReward(
        userId,
        req.params.rewardId,
        shippingAddress
      );
      res.json(redemption);
    } catch (error) {
      next(error);
    }
  }
);

router.get('/tiers', isAuthenticated, async (req, res, next) => {
  try {
    const tiers = await loyaltyService.getLoyaltyTiers(); // Await the promise
    res.json(tiers); // Return the resolved data
  } catch (error) {
    next(error);
  }
});

router.post('/admin/rewards', 
  isAuthenticated, 
  requireAdminRole, 
  validateRequest(loyaltyValidation.createRewardSchema),
  async (req, res, next) => {
    try {
      const reward = await loyaltyService.createReward(req.body);
      res.status(201).json(reward);
    } catch (error) {
      next(error);
    }
  }
);

router.put('/admin/tiers/:tierId', 
  isAuthenticated, 
  requireAdminRole, 
  validateRequest(loyaltyValidation.updateLoyaltyTierSchema),
  async (req, res, next) => {
    try {
      const tier = await loyaltyService.updateLoyaltyTier(
        req.params.tierId,
        req.body
      );
      res.json(tier);
    } catch (error) {
      next(error);
    }
  }
);

router.get('/admin/redemptions', 
  isAuthenticated, 
  requireAdminRole, 
  async (req, res, next) => {
    try {
      const { 
        page = 1, 
        limit = 10,
        status,
        startDate,
        endDate 
      } = req.query;

      const redemptions = await loyaltyService.getRewardRedemptions({
        page: Number(page),
        limit: Number(limit),
        status: status as string,
        startDate: startDate ? new Date(startDate as string) : undefined,
        endDate: endDate ? new Date(endDate as string) : undefined
      });
      res.json(redemptions);
    } catch (error) {
      next(error);
    }
  }
);

router.patch('/admin/redemptions/:redemptionId/status', 
  isAuthenticated, 
  requireAdminRole, 
  async (req, res, next) => {
    try {
      const { status, notes } = req.body;
      const redemption = await loyaltyService.updateRedemptionStatus(
        req.params.redemptionId,
        status,
        notes
      );
      res.json(redemption);
    } catch (error) {
      next(error);
    }
  }
);

router.get('/admin/pending-rewards', 
  isAuthenticated, 
  requireAdminRole, 
  async (req, res, next) => {
    try {
      const pendingRewards = await loyaltyService.getPendingPhysicalRewards(); // Await the promise
      res.json({ pendingRewards }); // Return the resolved data
    } catch (error) {
      next(error);
    }
  }
);

router.post('/admin/claim-reward/:redemptionId', 
  isAuthenticated, 
  requireAdminRole, 
  async (req, res, next) => {
    try {
      const success = await loyaltyService.verifyAndClaimPhysicalReward(
        req.params.redemptionId,
        req.user!.uid,
        req.body.notes
      );

      if (success) {
        res.json({ message: 'Reward claimed successfully' });
      } else {
        res.status(400).json({ error: 'Failed to claim reward' });
      }
    } catch (error) {
      next(error);
    }
  }
);

export default router;
