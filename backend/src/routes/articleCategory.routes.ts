import express from 'express';
import { ArticleCategoryController } from '../controllers/articleCategory.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

// Appliquer l'authentification à toutes les routes
router.use(authenticateToken);

// Routes publiques (nécessitent authentification mais pas d'autorisation spéciale)
router.get('/', asyncHandler(ArticleCategoryController.getAllArticleCategories));
router.get('/:categoryId', asyncHandler(ArticleCategoryController.getArticleCategoryById));

// Routes protégées (nécessitent le rôle ADMIN)
router.post(
  '/',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(ArticleCategoryController.createArticleCategory)
);

router.patch(
  '/:categoryId',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(ArticleCategoryController.updateArticleCategory)
);

router.delete(
  '/:categoryId',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(ArticleCategoryController.deleteArticleCategory)
);

export default router;
 