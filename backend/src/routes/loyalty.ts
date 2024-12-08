import express from 'express';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { LoyaltyController } from '../controllers/loyaltyController';
import { 
  validateCreateReward,
  validateUpdateReward,
  validateDeleteReward,
  validateGetRewards,
  validateGetRewardById,
  validateRedeemReward,
  validateGetLoyaltyProgram,
  validateUpdateLoyaltyProgram,
  validateGetUserPoints,
  validateAdjustUserPoints
} from '../middleware/loyaltyValidation';
import { UserRole } from '../models/user';

const router = express.Router();
const loyaltyController = new LoyaltyController();

// Protected routes requiring authentication
router.use(isAuthenticated);

// Admin-specific routes
router.use(requireAdminRolePath([UserRole.SUPER_ADMIN]));
router.post('/rewards', validateCreateReward, loyaltyController.createReward); // Apply validation directly
router.put('/rewards/:id', validateUpdateReward, loyaltyController.updateReward); // Apply validation directly
router.delete('/rewards/:id', validateDeleteReward, loyaltyController.deleteReward); // Apply validation directly
router.get('/rewards', validateGetRewards, loyaltyController.getRewards); // Apply validation directly
router.get('/rewards/:id', validateGetRewardById, loyaltyController.getRewardById); // Apply validation directly
router.put('/program', validateUpdateLoyaltyProgram, loyaltyController.updateLoyaltyProgram); // Apply validation directly

// User-specific routes
router.post('/redeem/:rewardId', validateRedeemReward, loyaltyController.redeemReward); // Apply validation directly
router.get('/program', validateGetLoyaltyProgram, loyaltyController.getLoyaltyProgram); // Apply validation directly
router.get('/points', validateGetUserPoints, loyaltyController.getUserPoints); // Apply validation directly

// Admin route for adjusting user points
router.post('/adjust/:userId', validateAdjustUserPoints, loyaltyController.adjustUserPoints); // Apply validation directly

export default router;
