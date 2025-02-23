import express from 'express';
import { PricingController } from '../controllers/pricing.controller';
import { authenticateToken } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

router.use(authenticateToken);

router.post('/calculate', 
  asyncHandler(PricingController.calculatePrice)
);

export default router;
  