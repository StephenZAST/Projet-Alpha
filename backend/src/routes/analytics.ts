import express from 'express';
import { authenticateUser } from '../middleware/auth';
import { requireSuperAdmin as requireAdmin } from '../middleware/auth';
import { AnalyticsService } from '../services/analytics';

const router = express.Router();
const analyticsService = new AnalyticsService();

router.get('/revenue', authenticateUser, requireAdmin, async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    const metrics = await analyticsService.getRevenueMetrics(
      new Date(startDate as string),
      new Date(endDate as string)
    );
    res.json(metrics);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch revenue metrics' });
  }
});

router.get('/customers', authenticateUser, requireAdmin, async (req, res) => {
  try {
    const metrics = await analyticsService.getCustomerMetrics();
    res.json(metrics);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch customer metrics' });
  }
});

router.get('/affiliates', authenticateUser, requireAdmin, async (req, res) => {
  try {
    const { startDate, endDate } = req.query;
    const metrics = await analyticsService.getAffiliateMetrics(
      new Date(startDate as string),
      new Date(endDate as string)
    );
    res.json(metrics);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch affiliate metrics' });
  }
});

export default router;

