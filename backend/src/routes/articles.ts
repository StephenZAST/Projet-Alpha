import express from 'express';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { createArticle, getArticles, updateArticle, deleteArticle, searchArticles } from '../services/articles';
import { validateArticleInput } from '../middleware/validation/index';
import { paginationMiddleware } from '../middleware/pagination';
import { searchArticlesSchema } from '../validations/schemas/articleSchemas';
import { validateRequest } from '../middleware/validateRequest';

const router = express.Router();

// Définir les champs de tri autorisés
const ALLOWED_SORT_FIELDS = ['createdAt', 'articleName', 'articleCategory', 'updatedAt'];

// Public route - anyone can view articles with pagination
router.get('/',
  paginationMiddleware(10, 50, ALLOWED_SORT_FIELDS),
  async (req, res, next) => {
    try {
      const articles = await getArticles(req.pagination);
      res.json(articles);
    } catch (error) {
      next(error);
    }
  }
);

// Route de recherche avec pagination et filtres
router.get('/search',
  paginationMiddleware(10, 50, ALLOWED_SORT_FIELDS),
  validateRequest(searchArticlesSchema),
  async (req, res, next) => {
    try {
      const searchParams = {
        query: req.query.query as string,
        category: req.query.category as string,
        minPrice: req.query.minPrice ? Number(req.query.minPrice) : undefined,
        maxPrice: req.query.maxPrice ? Number(req.query.maxPrice) : undefined,
        services: req.query.services ? (req.query.services as string).split(',') : undefined
      };

      const articles = await searchArticles(req.pagination, searchParams);
      res.json(articles);
    } catch (error) {
      next(error);
    }
  }
);

// Protected admin routes
router.post('/',
  isAuthenticated,
  requireAdminRole,
  validateArticleInput,
  async (req, res, next): Promise<void> => {
    try {
      const article = await createArticle(req.body);
      res.status(201).json(article);
    } catch (error) {
      next(error);
    }
  }
);

router.put('/:id',
  isAuthenticated,
  requireAdminRole,
  validateArticleInput,
  async (req, res, next): Promise<void> => {
    try {
      const articleId = req.params.id;
      const updatedArticle = await updateArticle(articleId, req.body);
      if (!updatedArticle) {
        res.status(404).json({ error: 'Article not found' });
        return;
      }
      res.json(updatedArticle);
    } catch (error) {
      next(error);
    }
  }
);

router.delete('/:id',
  isAuthenticated,
  requireAdminRole,
  async (req, res, next): Promise<void> => {
    try {
      const articleId = req.params.id;
      const deletedArticle = await deleteArticle(articleId);
      if (!deletedArticle) {
        res.status(404).json({ error: 'Article not found' });
        return;
      }
      res.json({ message: 'Article deleted successfully' });
    } catch (error) {
      next(error);
    }
  }
);

export default router;
