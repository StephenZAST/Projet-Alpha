import express, { Request, Response, NextFunction } from 'express';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { createArticle, getArticles, updateArticle, deleteArticle } from '../services/articles';
import { validateArticleRequest } from '../middleware/validation/index';
import { UserRole } from '../models/user';
import { PaginationParams } from '../utils/pagination';

const router = express.Router();

// Public route - anyone can view articles
router.get('/', (req: Request, res: Response, next: NextFunction) => {
  const paginationParams: PaginationParams = {
    page: 1,
    limit: 10,
    sortBy: 'createdAt',
    sortOrder: 'desc'
  };
  getArticles(paginationParams).then((articles) => {
    res.status(200).json({ articles });
  }).catch((error) => {
    next(error);
  });
});

// Protected admin routes
router.post('/', (req: Request, res: Response, next: NextFunction) => {
  createArticle(req.body).then((article) => {
    res.status(201).json({ article });
  }).catch((error) => {
    next(error);
  });
});

router.put('/:id', (req: Request, res: Response, next: NextFunction) => {
  const articleId = req.params.id;
  updateArticle(articleId, req.body).then((updatedArticle) => {
    if (!updatedArticle) {
      res.status(404).json({ error: 'Article not found' });
    } else {
      res.json(updatedArticle);
    }
  }).catch((error) => {
    next(error);
  });
});

router.delete('/:id', (req: Request, res: Response, next: NextFunction) => {
  const articleId = req.params.id;
  deleteArticle(articleId).then(() => {
    res.status(204).send();
  }).catch((error) => {
    next(error);
  });
});

export default router;
