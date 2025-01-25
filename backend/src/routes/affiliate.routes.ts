import { Router } from 'express';
import { AffiliateController } from '../controllers/affiliate.controller';
import { authMiddleware } from '../middleware/auth.middleware';

const router = Router();

// Routes pour les affiliés
router.get('/profile', authMiddleware, AffiliateController.getProfile);
router.put('/profile', authMiddleware, AffiliateController.updateProfile);
router.get('/commissions', authMiddleware, AffiliateController.getCommissions);
router.post('/withdrawal', authMiddleware, AffiliateController.requestWithdrawal);
router.get('/referrals', authMiddleware, AffiliateController.getReferrals);
router.get('/levels', AffiliateController.getLevels);
router.get('/current-level', authMiddleware, AffiliateController.getCurrentLevel);
router.post('/generate-code', authMiddleware, AffiliateController.generateAffiliateCode);

// Routes d'administration (requiert le rôle ADMIN)
router.get('/admin/list', 
  authMiddleware, 
  (req, res, next) => {
    if (req.user?.role !== 'ADMIN' && req.user?.role !== 'SUPER_ADMIN') {
      return res.status(403).json({ error: 'Admin access required' });
    }
    next();
  },
  AffiliateController.getAllAffiliates
);

// Gestion des demandes de retrait (admin)
router.get('/admin/withdrawals', 
  authMiddleware,
  (req, res, next) => {
    if (req.user?.role !== 'ADMIN' && req.user?.role !== 'SUPER_ADMIN') {
      return res.status(403).json({ error: 'Admin access required' });
    }
    next();
  },
  AffiliateController.getWithdrawals
);

// Rejet d'une demande de retrait (admin)
router.patch('/admin/withdrawals/:withdrawalId/reject',
  authMiddleware,
  (req, res, next) => {
    if (req.user?.role !== 'ADMIN' && req.user?.role !== 'SUPER_ADMIN') {
      return res.status(403).json({ error: 'Admin access required' });
    }
    next();
  },
  AffiliateController.rejectWithdrawal
);

// Mise à jour du statut d'un affilié (admin)
router.patch('/admin/affiliates/:affiliateId/status',
  authMiddleware,
  (req, res, next) => {
    if (req.user?.role !== 'ADMIN' && req.user?.role !== 'SUPER_ADMIN') {
      return res.status(403).json({ error: 'Admin access required' });
    }
    next();
  },
  AffiliateController.updateAffiliateStatus
);

// Création d'un client avec code affilié
router.post('/register-with-code', AffiliateController.createCustomerWithAffiliateCode);

export default router;
