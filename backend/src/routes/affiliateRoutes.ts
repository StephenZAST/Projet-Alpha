import express from 'express';
import { AffiliateController } from '../controllers/affiliateController';
import { authenticateUser, requireAdminRole, requireSecretaire } from '../middleware/auth'; // Correct import names

const router = express.Router();
const affiliateController = new AffiliateController();

// Routes publiques
router.post('/register', affiliateController.register);
router.post('/login', affiliateController.login);

// Routes protégées pour les affiliés
router.use(authenticateUser);
router.get('/profile', affiliateController.getProfile);
router.put('/profile', affiliateController.updateProfile);
router.get('/stats', affiliateController.getStats)
router.get('/commissions', affiliateController.getCommissions);
router.post('/withdrawal/request', affiliateController.requestWithdrawal);
router.get('/withdrawals', affiliateController.getWithdrawalHistory);

// Routes admin/secrétaire
router.use(requireSecretaire);
router.get('/pending', affiliateController.getPendingAffiliates);
router.post('/:id/approve', affiliateController.approveAffiliate);
router.get('/withdrawals/pending', affiliateController.getPendingWithdrawals);
router.post('/withdrawal/:id/process', affiliateController.processWithdrawal);

// Routes admin uniquement
router.use(requireAdminRole);
router.get('/all', affiliateController.getAllAffiliates);
router.post('/commission-rules', affiliateController.updateCommissionRules);
router.get('/analytics', affiliateController.getAnalytics);

export default router;
