import express from 'express';
import { ArticleServiceController } from '../controllers/articleService.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

router.use(authenticateToken);

// Routes publiques (clients)
router.get(
  '/',
  asyncHandler((req, res, next) => ArticleServiceController.getAllArticleServices(req, res))
);

// Routes admin
router.use(authorizeRoles(['ADMIN', 'SUPER_ADMIN']));

router.post(
  '/',
  asyncHandler((req, res, next) => ArticleServiceController.createArticleService(req, res))
);

router.put(
  '/:articleServiceId',
  asyncHandler((req, res, next) => ArticleServiceController.updateArticleService(req, res))
);

router.delete(
  '/:articleServiceId',
  asyncHandler((req, res, next) => ArticleServiceController.deleteArticleService(req, res))
);

export default router;
