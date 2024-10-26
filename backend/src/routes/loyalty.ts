
import express from 'express';
import { authenticateUser, requireAdmin } from '../middleware/auth';
import { LoyaltyService } from '../services/loyalty';

const router = express.Router();
const loyaltyService = new LoyaltyService();

// Get user's loyalty account
router.get('/account', authenticateUser, async (req, res) => {
  try {
    const account = await loyaltyService.getLoyaltyAccount(req.user!.uid);
    res.json({ account });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch loyalty account' });
  }
});

// Get available rewards
router.get('/rewards', authenticateUser, async (req, res) => {
  try {
    const rewards = await loyaltyService.getAvailableRewards(req.user!.uid);
    res.json({ rewards });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch rewards' });
  }
});

// Redeem a reward
router.post('/rewards/:rewardId/redeem', authenticateUser, async (req, res) => {
  try {
    const success = await loyaltyService.redeemReward(req.user!.uid, req.params.rewardId);
    if (success) {
      res.json({ message: 'Reward redeemed successfully' });
    } else {
      res.status(400).json({ error: 'Failed to redeem reward' });
    }
  } catch (error) {
    res.status(500).json({ error: 'Failed to redeem reward' });
  }
});

export default router;

// Admin routes for physical rewards
router.get('/admin/pending-rewards', authenticateUser, requireAdmin, async (req, res) => {
  try {
    const pendingRewards = await loyaltyService.getPendingPhysicalRewards();
    res.json({ pendingRewards });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch pending rewards' });
  }
});

router.post('/admin/claim-reward/:redemptionId', authenticateUser, requireAdmin, async (req, res) => {
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
    res.status(500).json({ error: 'Failed to claim reward' });
  }
});
