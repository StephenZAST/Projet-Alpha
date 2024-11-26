/* eslint-disable max-len */
/* eslint-disable no-unused-vars */
const express = require('express');
const admin = require('firebase-admin');
const { createSubscription, getSubscriptions, updateSubscription, deleteSubscription, getUserSubscription } = require('../../src/services/subscriptions');
const { AppError } = require('../../src/utils/errors');

const db = admin.firestore();
const router = express.Router();

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

// Public routes
router.get('/', async (req, res) => {
  try {
    const subscriptions = await getSubscriptions();
    res.json(subscriptions);
  } catch (error) {
    console.error('Error fetching subscriptions:', error);
    res.status(500).json({ error: 'Failed to retrieve subscriptions' });
  }
});

// User routes
router.get('/user/:userId', isAuthenticated, async (req, res) => {
  try {
    const subscription = await getUserSubscription(req.params.userId);
    res.json(subscription);
  } catch (error) {
    console.error('Error fetching user subscription:', error);
    res.status(500).json({ error: 'Failed to retrieve user subscription' });
  }
});

// Admin routes
router.post('/', isAuthenticated, requireAdminRole, async (req, res) => {
  try {
    const subscriptionData = req.body;
    const subscription = await createSubscription(subscriptionData);
    res.status(201).json(subscription);
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error creating subscription:', error);
    res.status(500).json({ error: 'Failed to create subscription' });
  }
});

router.put('/:id', isAuthenticated, requireAdminRole, async (req, res) => {
  try {
    const subscriptionId = req.params.id;
    const subscriptionData = req.body;
    const updatedSubscription = await updateSubscription(subscriptionId, subscriptionData);
    res.json(updatedSubscription);
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error updating subscription:', error);
    res.status(500).json({ error: 'Failed to update subscription' });
  }
});

router.delete('/:id', isAuthenticated, requireAdminRole, async (req, res) => {
  try {
    const subscriptionId = req.params.id;
    await deleteSubscription(subscriptionId);
    res.status(204).send(); // No content
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error deleting subscription:', error);
    res.status(500).json({ error: 'Failed to delete subscription' });
  }
});

module.exports = router;
