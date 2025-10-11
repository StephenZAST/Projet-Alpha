import express from 'express';
import { ArticleServiceController } from '../controllers/articleService.controller';
import { ArticleServicePriceController } from '../controllers/articleServicePrice.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler'; 

const router = express.Router();

// Routes publiques (pas d'authentification requise pour la lecture)
router.get('/prices', asyncHandler(ArticleServiceController.getAllPrices));
router.get('/:articleId/prices', asyncHandler(ArticleServiceController.getArticlePrices));
router.get('/couples', asyncHandler(ArticleServiceController.getCouplesForServiceType));

// Routes protégées (nécessitent authentification + rôle ADMIN)
router.post('/prices', 
  authenticateToken,
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(ArticleServiceController.createPrice)
);

router.put('/prices/:id', 
  authenticateToken,
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(ArticleServiceController.updatePrice)
);

router.delete('/prices/:id', 
  authenticateToken,
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(ArticleServicePriceController.delete)
);

export default router;
