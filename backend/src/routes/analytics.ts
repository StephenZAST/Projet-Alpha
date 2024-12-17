import express, { Request, Response, NextFunction } from 'express';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { AnalyticsService } from '../services/analytics';
import { UserRole } from '../models/user';

const router = express.Router();
const analyticsService = new AnalyticsService();

router.get('/revenue', (req: Request, res: Response, next: NextFunction) => {
  analyticsService.getRevenueMetrics(new Date(req.query.startDate as string), new Date(req.query.endDate as string)).then((metrics) => {
    res.status(200).json({ metrics });
  }).catch((error) => {
    next(error);
  });
});

export default router;
