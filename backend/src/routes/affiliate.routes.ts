import express from 'express';
import { AffiliateController } from '../controllers/affiliate.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

router.use(authenticateToken);
router.use(authorizeRoles(['AFFILIATE']));

// Endpoints principaux
router.get('/profile', asyncHandler(async (req, res) => {
  await AffiliateController.getProfile(req, res);
}));

router.put('/profile', asyncHandler(async (req, res) => {
  await AffiliateController.updateProfile(req, res);
}));

router.get('/commissions', asyncHandler(async (req, res) => {
  await AffiliateController.getCommissions(req, res);
}));

router.post('/withdraw', asyncHandler(async (req, res) => {
  await AffiliateController.requestWithdrawal(req, res);
}));

// Ajouter ces nouvelles routes
router.post('/generate-code', asyncHandler(async (req, res) => {
  await AffiliateController.generateAffiliateCode(req, res);
}));

router.post('/create-customer', asyncHandler(async (req, res) => {
  await AffiliateController.createCustomerWithAffiliateCode(req, res);
}));

// ...autres routes existantes...

export default router;
