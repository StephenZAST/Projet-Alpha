import express from 'express';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { createSubscription, getSubscriptions, updateSubscription, deleteSubscription, getUserSubscription } from '../services/subscriptions';
import { UserRole } from '../models/user';

const router = express.Router();

// Public routes
router.get('/', async (req, res, next): Promise<void> => {
  try {
    const subscriptions = await getSubscriptions();
    res.json(subscriptions);
  } catch (error) {
    next(error);
  }
});

// User routes
router.get('/user/:userId', isAuthenticated, async (req, res, next): Promise<void> => {
  try {
    const subscription = await getUserSubscription(req.params.userId);
    res.json(subscription);
  } catch (error) {
    next(error);
  }
});

// Admin routes
router.post('/', isAuthenticated, requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res, next): Promise<void> => {
  try {
    const subscription = await createSubscription(req.body);
    res.status(201).json(subscription);
  } catch (error) {
    next(error);
  }
});

router.put('/:id', isAuthenticated, requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res, next): Promise<void> => {
  try {
    const subscriptionId = req.params.id;
    const updatedSubscription = await updateSubscription(subscriptionId, req.body);
    if (!updatedSubscription) {
      res.status(404).json({ error: 'Subscription not found' }); // Removed return
    }
    res.json(updatedSubscription);
  } catch (error) {
    next(error);
  }
});

router.delete('/:id', isAuthenticated, requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res, next): Promise<void> => {
  try {
    const subscriptionId = req.params.id;
    await deleteSubscription(subscriptionId);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

export default router;
