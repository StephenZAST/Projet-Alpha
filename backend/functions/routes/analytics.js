const express = require('express');
const admin = require('firebase-admin');
const { AnalyticsService } = require('../../src/services/analytics');

const router = express.Router();
const analyticsService = new AnalyticsService();

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

router.get('/revenue', isAuthenticated, requireAdminRole, async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    const metrics = await analyticsService.getRevenueMetrics(
        new Date(startDate),
        new Date(endDate),
    );
    res.json(metrics);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch revenue metrics' });
  }
});

router.get('/customers', isAuthenticated, requireAdminRole, async (req, res) => {
  try {
    const metrics = await analyticsService.getCustomerMetrics();
    res.json(metrics);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch customer metrics' });
  }
});

router.get('/affiliates', isAuthenticated, requireAdminRole, async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    const metrics = await analyticsService.getAffiliateMetrics(
        new Date(startDate),
        new Date(endDate),
    );
    res.json(metrics);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch affiliate metrics' });
  }
});

module.exports = router;
