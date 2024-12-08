const express = require('express');
const admin = require('firebase-admin');
const { AffiliateService } = require('../../src/services/affiliateService');
const { CommissionService } = require('../../src/services/commissionService');
// eslint-disable-next-line no-unused-vars
const { AppError } = require('../../src/utils/errors');
const { requireAdminRolePath } = require('../../src/middleware/auth');
const { UserRole } = require('../../src/models/user');

const router = express.Router();
const affiliateService = new AffiliateService();
const commissionService = new CommissionService();

// Middleware to check if the user is authenticated
const isAuthenticated = (req, res, next) => {
  const idToken = req.headers.authorization?.split('Bearer ')[1];

  if (!idToken) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  admin.auth().verifyIdToken(idToken)
      .then(decodedToken => {
        req.user = decodedToken;
        next();
      })
      .catch(error => {
        console.error('Error verifying ID token:', error);
        res.status(401).json({ error: 'Unauthorized' });
      });
};

// Public routes
router.post('/register', affiliateService.register);
router.post('/login', affiliateService.login); // Placeholder for login

// Routes protégées pour les affiliés
router.use(isAuthenticated);
router.get('/profile', affiliateService.getProfile);
router.put('/profile', affiliateService.updateProfile);
router.get('/stats', affiliateService.getStats);
router.get('/commissions', affiliateService.getCommissions); // Placeholder for getCommissions
router.post('/withdrawal/request', affiliateService.requestWithdrawal);
router.get('/withdrawals', affiliateService.getWithdrawalHistory);

// Routes admin/secrétaire
router.use(requireAdminRolePath([UserRole.SUPER_ADMIN])); // Assuming admin/secretary have the same role
router.get('/pending', affiliateService.getPendingAffiliates);
router.post('/:id/approve', affiliateService.approveAffiliate);
router.get('/withdrawals/pending', affiliateService.getPendingWithdrawals);
router.post('/withdrawal/:id/process', affiliateService.processWithdrawal);

// Routes admin uniquement
router.get('/all', affiliateService.getAllAffiliates);
router.post('/commission-rules', commissionService.updateCommissionRules);
router.get('/analytics', affiliateService.getAnalytics);

module.exports = router;
