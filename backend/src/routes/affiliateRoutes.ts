import express from 'express';
import affiliateController from '../controllers/affiliateController';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { UserRole } from '../models/user';

const router = express.Router();

// Public routes
router.post('/register', affiliateController.createAffiliate);
router.post('/login', affiliateController.requestCommissionWithdrawal);

// Protected routes for affiliates
router.use(isAuthenticated);

router.get('/profile', affiliateController.getAffiliateProfile);
router.put('/profile', affiliateController.updateProfile);
router.get('/stats', affiliateController.getAffiliateStats);
router.get('/commissions', affiliateController.getCommissionWithdrawals);
router.post('/withdrawal/request', affiliateController.requestCommissionWithdrawal);
router.get('/withdrawals', affiliateController.getCommissionWithdrawals);

// Admin/Secretary routes
router.use(requireAdminRolePath([UserRole.ADMIN, UserRole.SECRETARY]));

router.get('/pending', affiliateController.getPendingAffiliates);
router.post('/:id/approve', affiliateController.approveAffiliate);
router.get('/withdrawals/pending', affiliateController.getPendingWithdrawals);
router.post('/withdrawal/:id/process', affiliateController.processWithdrawal);

// Admin-only routes
router.use(requireAdminRolePath([UserRole.SUPER_ADMIN]));

router.get('/all', affiliateController.getAllAffiliates);
router.post('/commission-rules', affiliateController.updateProfile);
router.get('/analytics', affiliateController.getAnalytics);

export default router;
