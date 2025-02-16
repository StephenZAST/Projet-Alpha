import express from 'express';
import { SubscriptionController } from '../controllers/subscription.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';
import { validateSubscription } from '../middleware/subscription.middleware';

const router = express.Router();

// Routes protégées
router.use(authenticateToken);

// Routes client
router.get(
  '/active',
  asyncHandler(SubscriptionController.getActiveSubscription)
);

router.post(
  '/subscribe',
  validateSubscription,
  asyncHandler(SubscriptionController.subscribeToPlan)
);

router.post(
  '/:subscriptionId/cancel',
  asyncHandler(SubscriptionController.cancelSubscription)
);

// Routes admin
router.post(
  '/plans',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(SubscriptionController.createPlan)
);

export default router;
 