import express from 'express';
import { ArticleCategoryController } from '../controllers/articleCategory.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

router.use(authenticateToken);

// Routes publiques (clients)
router.get(
  '/',
  asyncHandler((req, res, next) => ArticleCategoryController.getAllCategories(req, res))
);

// Routes admin
router.use(authorizeRoles(['ADMIN', 'SUPER_ADMIN']));

router.post(
  '/',
  asyncHandler((req, res, next) => ArticleCategoryController.createCategory(req, res))
);

router.put(
  '/:categoryId',
  asyncHandler((req, res, next) => ArticleCategoryController.updateCategory(req, res))
);

router.delete(
  '/:categoryId',
  asyncHandler((req, res, next) => ArticleCategoryController.deleteCategory(req, res))
);

export default router;
