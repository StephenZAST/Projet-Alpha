import express from 'express';
import { WeightPricingController } from '../controllers/weightPricing.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

// Routes protégées nécessitant une authentification
router.use(authenticateToken);

// Routes publiques avec protection admin
router.get('/', authorizeRoles(['ADMIN', 'SUPER_ADMIN']), 
  asyncHandler(WeightPricingController.getAll)
);

router.post('/', authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(WeightPricingController.create)
);

// Routes de calcul de prix
router.get('/calculate', 
  asyncHandler(WeightPricingController.calculatePrice)
);

router.patch('/:id', authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(WeightPricingController.update)
);

router.delete('/:id', authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(WeightPricingController.delete)
);

export default router;
