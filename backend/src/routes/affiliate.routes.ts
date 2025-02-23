import { Router } from 'express';
import { AffiliateController } from '../controllers/affiliate.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();

// Middleware pour vérifier les droits admin
const adminCheck = (req: any, res: any, next: any) => {
  if (req.user?.role !== 'ADMIN' && req.user?.role !== 'SUPER_ADMIN') {
    return res.status(403).json({ error: 'Admin access required' });
  }
  next();
};

// Routes pour les affiliés
router.get('/profile', authMiddleware, AffiliateController.getProfile);
router.put('/profile', authMiddleware, AffiliateController.updateProfile);
router.get('/commissions', authMiddleware, AffiliateController.getCommissions);
router.post('/withdrawal', authMiddleware, AffiliateController.requestWithdrawal);
router.get('/referrals', authMiddleware, AffiliateController.getReferrals);
router.get('/levels', AffiliateController.getLevels);
router.get('/current-level', authMiddleware, AffiliateController.getCurrentLevel);
router.post('/generate-code', authMiddleware, AffiliateController.generateAffiliateCode);

// Routes d'administration
router.get('/admin/list', 
  authMiddleware,
  adminCheck,
  AffiliateController.getAllAffiliates
); 
 
// Gestion des demandes de retrait (admin)
router.get('/admin/withdrawals/pending',
  authMiddleware,
  adminCheck,
  AffiliateController.getPendingWithdrawals
);

router.get('/admin/withdrawals',
  authMiddleware,
  adminCheck,
  AffiliateController.getWithdrawals
);

router.patch('/admin/withdrawals/:withdrawalId/reject',
  authMiddleware,
  adminCheck,
  AffiliateController.rejectWithdrawal
);

router.patch('/admin/withdrawals/:withdrawalId/approve',
  authMiddleware,
  adminCheck,
  AffiliateController.approveWithdrawal
);

// Mise à jour du statut d'un affilié (admin)
router.patch('/admin/affiliates/:affiliateId/status',
  authMiddleware,
  adminCheck,
  AffiliateController.updateAffiliateStatus
);

// Création d'un client avec code affilié
router.post('/register-with-code', AffiliateController.createCustomerWithAffiliateCode);

export default router;
