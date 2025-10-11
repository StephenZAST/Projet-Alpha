import express from 'express';
import { ArticleCategoryController } from '../controllers/articleCategory.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';
 
const router = express.Router();

// Routes publiques (pas d'authentification requise pour la lecture)
router.get('/', asyncHandler(ArticleCategoryController.getAllArticleCategories));
router.get('/:categoryId', asyncHandler(ArticleCategoryController.getArticleCategoryById));

// Routes protégées (nécessitent authentification + rôle ADMIN)
router.post(
  '/',
  authenticateToken,
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(ArticleCategoryController.createArticleCategory)
);

router.patch(
  '/:categoryId',
  authenticateToken,
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(ArticleCategoryController.updateArticleCategory)
);

router.delete(
  '/:categoryId',
  authenticateToken,
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  asyncHandler(ArticleCategoryController.deleteArticleCategory)
);

export default router;
  