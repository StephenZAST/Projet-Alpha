import express, { Request, Response, NextFunction } from 'express';
import { ArticleController } from '../controllers/article.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';
import { ArticleService } from '../services/article.service';

const router = express.Router();

// // Protection des routes avec authentification
// router.use(authenticateToken as express.RequestHandler);

// Routes admin
router.post(
  '/',
  // authorizeRoles(['ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await ArticleController.createArticle(req, res);
  })
);

router.get(
  '/:articleId',
  asyncHandler(async (req: Request, res: Response) => {
    await ArticleController.getArticleById(req, res);
  })
);

router.get(
  '/',
  asyncHandler(async (req: Request, res: Response) => {
    try {
      const articles = await ArticleService.getAllArticles();
      res.status(200).json({
        success: true,
        data: articles,
        message: 'Articles retrieved successfully'
      });
    } catch (error) {
      console.error('Error getting articles:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to retrieve articles',
        error: error instanceof Error ? error.message : 'Database error'
      });
    }
  })
);

router.patch(
  '/:articleId',
  authorizeRoles(['ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await ArticleController.updateArticle(req, res);
  })
);

router.delete(
  '/:articleId',
  authorizeRoles(['ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await ArticleController.deleteArticle(req, res);
  })
);

export default router;
