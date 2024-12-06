import express from 'express';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { AnalyticsService } from '../services/analytics';

const router = express.Router();
const analyticsService = new AnalyticsService();

router.get('/revenue', isAuthenticated, requireAdminRole, async (req, res, next) => {
  try {
    const { startDate, endDate } = req.query;
    const metrics = await analyticsService.getRevenueMetrics(
      new Date(startDate as string),
      new Date(endDate as string)
    );
    res.json(metrics);
  } catch (error) {
    next(error);
  }
});

// ... (rest of the code remains the same)
