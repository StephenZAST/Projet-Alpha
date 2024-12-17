import express, { Request, Response, NextFunction } from 'express';
import affiliateController from '../controllers/affiliateController';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { UserRole } from '../models/user';

const router = express.Router();

// Public routes
router.post('/register', (req: Request, res: Response, next: NextFunction) => {
  affiliateController.createAffiliate(req, res, next);
});

router.post('/login', (req: Request, res: Response, next: NextFunction) => {
  affiliateController.requestCommissionWithdrawal(req, res, next);
});

// Protected routes for affiliates
router.use(isAuthenticated as express.RequestHandler);

router.get('/profile', (req: Request, res: Response, next: NextFunction) => {
  affiliateController.getAffiliateProfile(req, res, next);
});

router.put('/profile', (req: Request, res: Response, next: NextFunction) => {
  affiliateController.updateProfile(req, res, next);
});

router.get('/stats', (req: Request, res: Response, next: NextFunction) => {
  affiliateController.getAffiliateStats(req, res, next);
});

router.get('/commissions', (req: Request, res: Response, next: NextFunction) => {
  affiliateController.getCommissionWithdrawals(req, res, next);
});

router.post('/withdrawal/request', (req: Request, res: Response, next: NextFunction) => {
  affiliateController.requestCommissionWithdrawal(req, res, next);
});

router.get('/withdrawals', (req: Request, res: Response, next: NextFunction) => {
  affiliateController.getCommissionWithdrawals(req, res, next);
});

// Admin/Secretary routes
router.use(requireAdminRolePath([UserRole.ADMIN, UserRole.SECRETARY]) as express.RequestHandler);

router.get('/pending', (req: Request, res: Response, next: NextFunction) => {
  affiliateController.getPendingAffiliates(req, res, next);
});

router.post('/:id/approve', (req: Request, res: Response, next: NextFunction) => {
  affiliateController.approveAffiliate(req, res, next);
});

router.get('/withdrawals/pending', (req: Request, res: Response, next: NextFunction) => {
  affiliateController.getPendingWithdrawals(req, res, next);
});

router.post('/withdrawal/:id/process', (req: Request, res: Response, next: NextFunction) => {
  affiliateController.processWithdrawal(req, res, next);
});

// Admin-only routes
router.use(requireAdminRolePath([UserRole.SUPER_ADMIN]) as express.RequestHandler);

router.get('/all', (req: Request, res: Response, next: NextFunction) => {
  affiliateController.getAllAffiliates(req, res, next);
});

router.post('/commission-rules', (req: Request, res: Response, next: NextFunction) => {
  affiliateController.updateAffiliate(req, res, next);
});

router.get('/analytics', (req: Request, res: Response, next: NextFunction) => {
  affiliateController.getAnalytics(req, res, next);
});

export default router;
