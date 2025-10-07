import { Router } from 'express';
import { AffiliateController } from '../controllers/affiliate.controller';
import { authenticateToken, authMiddleware } from '../middleware/auth.middleware';
import { debugMiddleware } from '../middleware/debug.middleware';
import affiliateLinkRoutes from './affiliateLink.routes';

const router = Router();

// Ajouter le middleware de debug en développement
if (process.env.NODE_ENV !== 'production') {
  router.use(debugMiddleware);
}

// Middleware pour vérifier les droits admin
const adminCheck = (req: any, res: any, next: any) => {
  if (req.user?.role !== 'ADMIN' && req.user?.role !== 'SUPER_ADMIN') {
    return res.status(403).json({ error: 'Admin access required' });
  }
  next();
};

// Routes pour les affiliés
router.get('/profile', authMiddleware, AffiliateController.getProfile);
router.post('/create-profile', authMiddleware, AffiliateController.createProfile);
router.put('/profile', authMiddleware, AffiliateController.updateProfile);
router.get('/commissions', authMiddleware, AffiliateController.getCommissions);
router.post('/withdrawal', authMiddleware, AffiliateController.requestWithdrawal);
router.get('/referrals', authMiddleware, AffiliateController.getReferrals);
router.get('/levels', AffiliateController.getLevels);
router.get('/current-level', authMiddleware, AffiliateController.getCurrentLevel);
router.post('/generate-code', authMiddleware, AffiliateController.generateAffiliateCode);

// Routes d'administration
router.get('/admin/list', authenticateToken, adminCheck, AffiliateController.getAllAffiliates);
router.get('/admin/stats', authenticateToken, adminCheck, AffiliateController.getAffiliateStats);
router.get('/admin/withdrawals/pending', authenticateToken, adminCheck, AffiliateController.getPendingWithdrawals);
router.get('/admin/withdrawals', authenticateToken, adminCheck, AffiliateController.getWithdrawals);
router.patch('/admin/withdrawals/:withdrawalId/reject', authenticateToken, adminCheck, AffiliateController.rejectWithdrawal);
router.patch('/admin/withdrawals/:withdrawalId/approve', authenticateToken, adminCheck, AffiliateController.approveWithdrawal);
router.patch('/admin/affiliates/:affiliateId/status', authenticateToken, adminCheck, AffiliateController.updateAffiliateStatus);

// Création d'un client avec code affilié
router.post('/register-with-code', AffiliateController.createCustomerWithAffiliateCode);

// Routes pour les liens d'affiliation
router.use(affiliateLinkRoutes);

export default router;
