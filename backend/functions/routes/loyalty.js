const express = require('express');
const admin = require('firebase-admin');
const { LoyaltyService } = require('../../src/services/loyalty');
const { AppError } = require('../../src/utils/errors');

const router = express.Router();
const loyaltyService = new LoyaltyService();

// Middleware to check if the user is authenticated
const isAuthenticated = (req, res, next) => {
  const idToken = req.headers.authorization?.split('Bearer ')[1];

  if (!idToken) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  admin.auth().verifyIdToken(idToken)
      .then(decodedToken => {
        req.user = decodedToken;
        next();
      })
      .catch(error => {
        console.error('Error verifying ID token:', error);
        res.status(401).json({ error: 'Unauthorized' });
      });
};

// Middleware to check if the user has the admin role
const requireAdminRole = (req, res, next) => {
  if (req.user?.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }
  next();
};

// Apply authentication middleware to all routes
router.use(isAuthenticated);

// GET /loyalty/account
router.get('/account', async (req, res) => {
  try {
    const account = await loyaltyService.getLoyaltyAccount(req.user.uid);
    res.json(account);
  } catch (error) {
    console.error('Error fetching loyalty account:', error);
    res.status(500).json({ error: 'Failed to fetch loyalty account' });
  }
});

// GET /loyalty/points/history
router.get('/points/history', async (req, res) => {
  try {
    const { page = 1, limit = 10 } = req.query;
    const history = await loyaltyService.getPointsHistory(
        req.user.uid,
        Number(page),
        Number(limit),
    );
    res.json(history);
  } catch (error) {
    console.error('Error fetching points history:', error);
    res.status(500).json({ error: 'Failed to fetch points history' });
  }
});

// GET /loyalty/rewards
router.get('/rewards', async (req, res) => {
  try {
    const { type, category, status } = req.query;
    const rewards = await loyaltyService.getAvailableRewards(req.user.uid, {
      type: type,
      category: category,
      status: status,
    });
    res.json(rewards);
  } catch (error) {
    console.error('Error fetching available rewards:', error);
    res.status(500).json({ error: 'Failed to fetch available rewards' });
  }
});

// POST /loyalty/rewards/:rewardId/redeem
router.post('/rewards/:rewardId/redeem', async (req, res) => {
  try {
    const { shippingAddress } = req.body;
    const redemption = await loyaltyService.redeemReward(
        req.user.uid,
        req.params.rewardId,
        shippingAddress,
    );
    res.json(redemption);
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error redeeming reward:', error);
    res.status(500).json({ error: 'Failed to redeem reward' });
  }
});

// GET /loyalty/tiers
router.get('/tiers', async (req, res) => {
  try {
    const tiers = await loyaltyService.getLoyaltyTiers();
    res.json(tiers);
  } catch (error) {
    console.error('Error fetching loyalty tiers:', error);
    res.status(500).json({ error: 'Failed to fetch loyalty tiers' });
  }
});

// Admin-only routes
router.use(requireAdminRole);

// POST /loyalty/admin/rewards
router.post('/admin/rewards', async (req, res) => {
  try {
    const reward = await loyaltyService.createReward(req.body);
    res.status(201).json(reward);
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error creating reward:', error);
    res.status(500).json({ error: 'Failed to create reward' });
  }
});

// PUT /loyalty/admin/tiers/:tierId
router.put('/admin/tiers/:tierId', async (req, res) => {
  try {
    const tier = await loyaltyService.updateLoyaltyTier(
        req.params.tierId,
        req.body,
    );
    res.json(tier);
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error updating loyalty tier:', error);
    res.status(500).json({ error: 'Failed to update loyalty tier' });
  }
});

// GET /loyalty/admin/redemptions
router.get('/admin/redemptions', async (req, res) => {
  try {
    const {
      page = 1,
      limit = 10,
      status,
      startDate,
      endDate,
    } = req.query;

    const redemptions = await loyaltyService.getRewardRedemptions({
      page: Number(page),
      limit: Number(limit),
      status: status,
      startDate: startDate ? new Date(startDate) : undefined,
      endDate: endDate ? new Date(endDate) : undefined,
    });
    res.json(redemptions);
  } catch (error) {
    console.error('Error fetching reward redemptions:', error);
    res.status(500).json({ error: 'Failed to fetch reward redemptions' });
  }
});

// PATCH /loyalty/admin/redemptions/:redemptionId/status
router.patch('/admin/redemptions/:redemptionId/status', async (req, res) => {
  try {
    const { status, notes } = req.body;
    const redemption = await loyaltyService.updateRedemptionStatus(
        req.params.redemptionId,
        status,
        notes,
    );
    res.json(redemption);
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error updating redemption status:', error);
    res.status(500).json({ error: 'Failed to update redemption status' });
  }
});

// GET /loyalty/admin/pending-rewards
router.get('/admin/pending-rewards', async (req, res) => {
  try {
    const pendingRewards = await loyaltyService.getPendingPhysicalRewards();
    res.json({ pendingRewards });
  } catch (error) {
    console.error('Error fetching pending physical rewards:', error);
    res.status(500).json({ error: 'Failed to fetch pending physical rewards' });
  }
});

// POST /loyalty/admin/claim-reward/:redemptionId
router.post('/admin/claim-reward/:redemptionId', async (req, res) => {
  try {
    const success = await loyaltyService.verifyAndClaimPhysicalReward(
        req.params.redemptionId,
        req.user.uid,
        req.body.notes,
    );

    if (success) {
      res.json({ message: 'Reward claimed successfully' });
    } else {
      res.status(400).json({ error: 'Failed to claim reward' });
    }
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error claiming reward:', error);
    res.status(500).json({ error: 'Failed to claim reward' });
  }
});

module.exports = router;
