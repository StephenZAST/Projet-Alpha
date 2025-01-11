import express, { Request, Response, NextFunction } from 'express';
import { ArticleCategoryController } from '../controllers/articleCategory.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

// // Protection des routes avec authentification
// router.use(authenticateToken as express.RequestHandler);

// Routes admin
router.post(
  '/',
  // authorizeRoles(['ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await ArticleCategoryController.createArticleCategory(req, res);
  })
);

router.get(
  '/:categoryId',
  asyncHandler(async (req: Request, res: Response) => {
    await ArticleCategoryController.getArticleCategoryById(req, res);
  })
);

router.get(
  '/',
  asyncHandler(async (req: Request, res: Response) => {
    await ArticleCategoryController.getAllArticleCategories(req, res);
  })
);

router.patch(
  '/:categoryId',
  authorizeRoles(['ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await ArticleCategoryController.updateArticleCategory(req, res);
  })
);

router.delete(
  '/:categoryId',
  authorizeRoles(['ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await ArticleCategoryController.deleteArticleCategory(req, res);
  })
);

export default router;
