import express from 'express';
import { ArticleController } from '../controllers/article.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler'; 

const router = express.Router();

// Routes publiques
router.get('/', asyncHandler(ArticleController.getAllArticles));
router.get('/category/:categoryId', asyncHandler(ArticleController.getArticlesByCategory));
router.get('/:articleId', asyncHandler(ArticleController.getArticleById));

// Routes protégées - nécessitent authentification
router.use(authenticateToken);

// Routes CRUD - Accessibles aux admins
router.post(
  '/',
  asyncHandler(ArticleController.createArticle)
);

router.patch(
  '/:articleId',
  asyncHandler(ArticleController.updateArticle) // Suppression de la restriction ADMIN
);

router.delete(
  '/:articleId',
  asyncHandler(ArticleController.deleteArticle)
);

router.post('/:articleId/archive', authorizeRoles(['ADMIN']), asyncHandler(ArticleController.archiveArticle));

export default router;
  