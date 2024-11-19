import express from 'express';
import { authenticateUser, requireSuperAdmin } from '../middleware/auth';
import { validateRequest } from '../middleware/validateRequest';
import { 
  redeemRewardSchema,
  updateLoyaltyTierSchema,
  createRewardSchema
} from '../validation/loyalty';
import { LoyaltyService } from '../services/loyalty';
import { AppError } from '../utils/errors';

const router = express.Router();
const loyaltyService = new LoyaltyService();

/**
 * @swagger
 * /api/loyalty/account:
 *   get:
 *     tags: [Loyalty]
 *     summary: Get user's loyalty account details
 *     security:
 *       - bearerAuth: []
 */
router.get('/account', authenticateUser, async (req, res, next) => {
  try {
    const account = await loyaltyService.getLoyaltyAccount(req.user!.uid);
    res.json(account);
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/loyalty/points/history:
 *   get:
 *     tags: [Loyalty]
 *     summary: Get user's points history
 *     security:
 *       - bearerAuth: []
 */
router.get('/points/history', authenticateUser, async (req, res, next) => {
  try {
    const { page = 1, limit = 10 } = req.query;
    const history = await loyaltyService.getPointsHistory(
      req.user!.uid,
      Number(page),
      Number(limit)
    );
    res.json(history);
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/loyalty/rewards:
 *   get:
 *     tags: [Loyalty]
 *     summary: Get available rewards
 *     security:
 *       - bearerAuth: []
 */
router.get('/rewards', authenticateUser, async (req, res, next) => {
  try {
    const { type, category, status } = req.query;
    const rewards = await loyaltyService.getAvailableRewards(req.user!.uid, {
      type: type as string,
      category: category as string,
      status: status as string
    });
    res.json(rewards);
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/loyalty/rewards/{rewardId}/redeem:
 *   post:
 *     tags: [Loyalty]
 *     summary: Redeem a reward
 *     security:
 *       - bearerAuth: []
 */
router.post(
  '/rewards/:rewardId/redeem',
  authenticateUser,
  validateRequest(redeemRewardSchema),
  async (req, res, next) => {
    try {
      const { shippingAddress } = req.body;
      const redemption = await loyaltyService.redeemReward(
        req.user!.uid,
        req.params.rewardId,
        shippingAddress
      );
      res.json(redemption);
    } catch (error) {
      next(error);
    }
  }
);

/**
 * @swagger
 * /api/loyalty/tiers:
 *   get:
 *     tags: [Loyalty]
 *     summary: Get all loyalty tiers
 *     security:
 *       - bearerAuth: []
 */
router.get('/tiers', authenticateUser, async (req, res, next) => {
  try {
    const tiers = await loyaltyService.getLoyaltyTiers();
    res.json(tiers);
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/loyalty/admin/rewards:
 *   post:
 *     tags: [Loyalty]
 *     summary: Create a new reward (Admin only)
 *     security:
 *       - bearerAuth: []
 */
router.post(
  '/admin/rewards',
  authenticateUser,
  requireSuperAdmin,
  validateRequest(createRewardSchema),
  async (req, res, next) => {
    try {
      const reward = await loyaltyService.createReward(req.body);
      res.status(201).json(reward);
    } catch (error) {
      next(error);
    }
  }
);

/**
 * @swagger
 * /api/loyalty/admin/tiers/{tierId}:
 *   put:
 *     tags: [Loyalty]
 *     summary: Update loyalty tier (Admin only)
 *     security:
 *       - bearerAuth: []
 */
router.put(
  '/admin/tiers/:tierId',
  authenticateUser,
  requireSuperAdmin,
  validateRequest(updateLoyaltyTierSchema),
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

/**
 * @swagger
 * /api/loyalty/admin/redemptions:
 *   get:
 *     tags: [Loyalty]
 *     summary: Get all reward redemptions (Admin only)
 *     security:
 *       - bearerAuth: []
 */
router.get(
  '/admin/redemptions',
  authenticateUser,
  requireSuperAdmin,
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

/**
 * @swagger
 * /api/loyalty/admin/redemptions/{redemptionId}/status:
 *   patch:
 *     tags: [Loyalty]
 *     summary: Update redemption status (Admin only)
 *     security:
 *       - bearerAuth: []
 */
router.patch(
  '/admin/redemptions/:redemptionId/status',
  authenticateUser,
  requireSuperAdmin,
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

// Admin routes for physical rewards
router.get('/admin/pending-rewards', authenticateUser, requireSuperAdmin, async (req, res, next) => {
  try {
    const pendingRewards = await loyaltyService.getPendingPhysicalRewards();
    res.json({ pendingRewards });
  } catch (error) {
    next(error);
  }
});

router.post('/admin/claim-reward/:redemptionId', authenticateUser, requireSuperAdmin, async (req, res, next) => {
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
});

export default router;
