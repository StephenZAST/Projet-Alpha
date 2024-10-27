import express from 'express';
import { authenticateUser, requireAdmin } from '../middleware/auth';
import { createSubscription, getSubscriptions, updateSubscription, deleteSubscription, getUserSubscription } from '../services/subscriptions';

const router = express.Router();

// Public routes
router.get('/', async (req, res, next) => {
  try {
    const subscriptions = await getSubscriptions();
    res.json(subscriptions);
  } catch (error) {
    next(error);
  }
});

// User routes
router.get('/user/:userId', authenticateUser, async (req, res, next) => {
  try {
    const subscription = await getUserSubscription(req.params.userId);
    res.json(subscription);
  } catch (error) {
    next(error);
  }
});

// Admin routes
router.post('/', authenticateUser, requireAdmin, async (req, res, next) => {
  try {
    const subscription = await createSubscription(req.body);
    res.status(201).json(subscription);
  } catch (error) {
    next(error);
  }
});

router.put('/:id', authenticateUser, requireAdmin, async (req, res, next) => {
  try {
    const subscriptionId = req.params.id;
    const updatedSubscription = await updateSubscription(subscriptionId, req.body);
    if (!updatedSubscription) {
      return res.status(404).json({ error: 'Subscription not found' });
    }
    res.json(updatedSubscription);
  } catch (error) {
    next(error);
  }
});

router.delete('/:id', authenticateUser, requireAdmin, async (req, res, next) => {
  try {
    const subscriptionId = req.params.id;
    await deleteSubscription(subscriptionId);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

export default router;
