import express from 'express';
import { BlogCategoryController } from '../controllers/blogCategory.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

router.use(authenticateToken);

// Routes publiques (clients)
router.get(
  '/',
  asyncHandler((req, res, next) => BlogCategoryController.getAllCategories(req, res))
);

// Routes admin
router.use(authorizeRoles(['ADMIN', 'SUPER_ADMIN']));

router.post(
  '/',
  asyncHandler((req, res, next) => BlogCategoryController.createCategory(req, res))
);

router.put(
  '/:categoryId',
  asyncHandler((req, res, next) => BlogCategoryController.updateCategory(req, res))
);

router.delete(
  '/:categoryId',
  asyncHandler((req, res, next) => BlogCategoryController.deleteCategory(req, res))
);

export default router;
