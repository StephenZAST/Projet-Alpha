import express from 'express';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { createArticle, getArticles, updateArticle, deleteArticle } from '../services/articles';
import { validateArticleInput } from '../middleware/validation/index';
import { UserRole } from '../models/user';
import { PaginationParams } from '../utils/pagination';

const router = express.Router();

// Public route - anyone can view articles
router.get('/', async (req, res, next) => {
  try {
    const paginationParams: PaginationParams = {
      page: 1,
      limit: 10,
      sortBy: 'createdAt',
      sortOrder: 'desc'
    };
    const articles = await getArticles(paginationParams);
    res.json(articles);
  } catch (error) {
    next(error);
  }
});

// Protected admin routes
router.post('/', isAuthenticated, requireAdminRolePath([UserRole.SUPER_ADMIN]), validateArticleInput, async (req, res, next) => {
  try {
    const article = await createArticle(req.body);
    res.status(201).json(article);
  } catch (error) {
    next(error);
  }
});

router.put('/:id', isAuthenticated, requireAdminRolePath([UserRole.SUPER_ADMIN]), validateArticleInput, async (req, res, next) => {
  try {
    const articleId = req.params.id;
    const updatedArticle = await updateArticle(articleId, req.body);
    if (!updatedArticle) {
      res.status(404).json({ error: 'Article not found' });
    }
    res.json(updatedArticle);
  } catch (error) {
    next(error);
  }
});

router.delete('/:id', isAuthenticated, requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res, next) => {
  try {
    const articleId = req.params.id;
    await deleteArticle(articleId);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

export default router;
