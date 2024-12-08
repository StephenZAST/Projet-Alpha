import express from 'express';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { AnalyticsService } from '../services/analytics';
import { UserRole } from '../models/user';

const router = express.Router();
const analyticsService = new AnalyticsService();

router.get('/revenue', isAuthenticated, requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res, next) => {
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

