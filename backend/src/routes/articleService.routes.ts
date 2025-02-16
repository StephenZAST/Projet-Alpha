import express from 'express';
import { ArticleServiceController } from '../controllers/articleService.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

router.use(authenticateToken);

// Routes publiques
router.get('/prices', asyncHandler(ArticleServiceController.getAllPrices));
router.get('/:articleId/prices', asyncHandler(ArticleServiceController.getArticlePrices));

// Routes admin
router.use(authorizeRoles(['ADMIN', 'SUPER_ADMIN']));
router.post('/prices', asyncHandler(ArticleServiceController.createPrice));
router.put('/prices/:id', asyncHandler(ArticleServiceController.updatePrice));

export default router;
 