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

/**
 * @swagger
 * tags:
 *   name: Analytics
 *   description: Business analytics and reporting endpoints
 */

/**
 * @swagger
 * components:
 *   schemas:
 *     RevenueMetrics:
 *       type: object
 *       properties:
 *         totalRevenue:
 *           type: number
 *           description: Total revenue for the specified period
 *         periodRevenue:
 *           type: number
 *           description: Revenue for the current period
 *         orderCount:
 *           type: integer
 *           description: Total number of orders in the period
 *         averageOrderValue:
 *           type: number
 *           description: Average value per order
 *         revenueByService:
 *           type: object
 *           additionalProperties:
 *             type: number
 *           description: Revenue breakdown by service type
 *         periodStart:
 *           type: string
 *           format: date-time
 *           description: Start date of the period
 *         periodEnd:
 *           type: string
 *           format: date-time
 *           description: End date of the period
 *     CustomerMetrics:
 *       type: object
 *       properties:
 *         totalCustomers:
 *           type: integer
 *           description: Total number of customers
 *         activeCustomers:
 *           type: integer
 *           description: Number of customers active in the last 90 days
 *         customerRetentionRate:
 *           type: number
 *           description: Customer retention rate as a percentage
 *         topCustomers:
 *           type: array
 *           items:
 *             type: object
 *             properties:
 *               userId:
 *                 type: string
 *               totalSpent:
 *                 type: number
 *               orderCount:
 *                 type: integer
 *               loyaltyTier:
 *                 type: string
 *               lastOrderDate:
 *                 type: string
 *                 format: date-time
 *         customersByTier:
 *           type: object
 *           additionalProperties:
 *             type: integer
 *           description: Number of customers in each loyalty tier
 *     AffiliateMetrics:
 *       type: object
 *       properties:
 *         totalAffiliates:
 *           type: integer
 *           description: Total number of affiliates
 *         activeAffiliates:
 *           type: integer
 *           description: Number of affiliates with active customers
 *         totalCommission:
 *           type: number
 *           description: Total commission paid to affiliates
 *         topAffiliates:
 *           type: array
 *           items:
 *             type: object
 *             properties:
 *               affiliateId:
 *                 type: string
 *               activeCustomers:
 *                 type: integer
 *               totalCommission:
 *                 type: number
 *     Error:
 *       type: object
 *       properties:
 *         error:
 *           type: string
 *           description: Error message
 */

/**
 * @swagger
 * /api/analytics/revenue:
 *   get:
 *     summary: Get revenue analytics
 *     description: Retrieve detailed revenue metrics for a specified time period
 *     tags: [Analytics]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: startDate
 *         required: true
 *         schema:
 *           type: string
 *           format: date
 *         description: Start date for the analysis period (YYYY-MM-DD)
 *       - in: query
 *         name: endDate
 *         required: true
 *         schema:
 *           type: string
 *           format: date
 *         description: End date for the analysis period (YYYY-MM-DD)
 *     responses:
 *       200:
 *         description: Revenue metrics retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/RevenueMetrics'
 *       401:
 *         description: Unauthorized - User not authenticated
 *       403:
 *         description: Forbidden - User not authorized
 *       500:
 *         description: Internal server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
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

/**
 * @swagger
 * /api/analytics/customers:
 *   get:
 *     summary: Get customer analytics
 *     description: Retrieve detailed customer metrics including retention and loyalty statistics
 *     tags: [Analytics]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Customer metrics retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/CustomerMetrics'
 *       401:
 *         description: Unauthorized - User not authenticated
 *       403:
 *         description: Forbidden - User not authorized
 *       500:
 *         description: Internal server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get('/customers', isAuthenticated, requireAdminRole, async (req, res) => {
  try {
    const metrics = await analyticsService.getCustomerMetrics();
    res.json(metrics);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch customer metrics' });
  }
});

/**
 * @swagger
 * /api/analytics/affiliates:
 *   get:
 *     summary: Get affiliate analytics
 *     description: Retrieve detailed affiliate performance metrics for a specified time period
 *     tags: [Analytics]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: startDate
 *         required: true
 *         schema:
 *           type: string
 *           format: date
 *         description: Start date for the analysis period (YYYY-MM-DD)
 *       - in: query
 *         name: endDate
 *         required: true
 *         schema:
 *           type: string
 *           format: date
 *         description: End date for the analysis period (YYYY-MM-DD)
 *     responses:
 *       200:
 *         description: Affiliate metrics retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/AffiliateMetrics'
 *       401:
 *         description: Unauthorized - User not authenticated
 *       403:
 *         description: Forbidden - User not authorized
 *       500:
 *         description: Internal server error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
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
