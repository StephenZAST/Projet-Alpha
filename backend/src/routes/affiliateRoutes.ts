import express from 'express';
import { affiliateController } from '../controllers/affiliateController';
import { isAuthenticated, requireAdminRole, auth } from '../middleware/auth';

const router = express.Router();

router.post('/register', affiliateController.createAffiliate);
router.post('/login', affiliateController.requestCommissionWithdrawal);

// Routes protégées pour les affiliés
router.use(isAuthenticated);

router.get('/profile', affiliateController.getAffiliateById);
router.put('/profile', affiliateController.updateAffiliate);
router.get('/stats', affiliateController.getAllAffiliates);
router.get('/commissions', affiliateController.getCommissionWithdrawals);
router.post('/withdrawal/request', affiliateController.requestCommissionWithdrawal);
router.get('/withdrawals', affiliateController.getCommissionWithdrawals);

// Routes admin/secrétaire
router.use(auth);

router.get('/pending', affiliateController.getAllAffiliates);
router.post('/:id/approve', affiliateController.updateCommissionWithdrawalStatus);
router.get('/withdrawals/pending', affiliateController.getCommissionWithdrawals);
router.post('/withdrawal/:id/process', affiliateController.updateCommissionWithdrawalStatus);

// Routes admin uniquement
router.use(requireAdminRole);

router.get('/all', affiliateController.getAllAffiliates);
router.post('/commission-rules', affiliateController.updateAffiliate);
router.get('/analytics', affiliateController.getAllAffiliates);

export default router;
