import express from 'express';
import { WeightPricingController } from '../controllers/weightPricing.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';
import { validateWeightPricing } from '../middleware/validation/weightPricing.validation';

const router = express.Router();

router.use(authenticateToken);

// Routes publiques (requiert authentification)
router.post('/calculate', 
  validateWeightPricing.calculatePrice,
  asyncHandler(WeightPricingController.calculatePrice)
);

// Routes admin
router.use(authorizeRoles(['ADMIN', 'SUPER_ADMIN']));

router.post('/',
  validateWeightPricing.createPricing,
  asyncHandler(WeightPricingController.setWeightPrice)
);

export default router;
