import express from 'express';
import { ArticleController } from '../controllers/article.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

router.use(authenticateToken);

// Routes publiques (clients)
router.get(
  '/',
  asyncHandler((req, res, next) => ArticleController.getAllArticles(req, res))
);

// Routes admin
router.use(authorizeRoles(['ADMIN', 'SUPER_ADMIN']));

router.post(
  '/',
  asyncHandler((req, res, next) => ArticleController.createArticle(req, res))
);

router.put(
  '/:articleId',
  asyncHandler((req, res, next) => ArticleController.updateArticle(req, res))
);

router.delete(
  '/:articleId',
  asyncHandler((req, res, next) => ArticleController.deleteArticle(req, res))
);

export default router;
