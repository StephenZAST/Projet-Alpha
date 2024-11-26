import express from 'express';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { createArticle, getArticles, updateArticle, deleteArticle } from '../services/articles';
import { validateArticleInput } from '../middleware/validation/index';


const router = express.Router();

// Public route - anyone can view articles
router.get('/', async (req, res, next) => {
  try {
    const articles = await getArticles();
    res.json(articles);
  } catch (error) {
    next(error);
  }
});

// Protected admin routes
router.post('/', isAuthenticated, requireAdminRole, validateArticleInput, async (req, res, next): Promise<void> => {
  try {
    const article = await createArticle(req.body);
    res.status(201).json(article);
  } catch (error) {
    next(error);
  }
});

router.put('/:id', isAuthenticated, requireAdminRole, validateArticleInput, async (req, res, next): Promise<void> => {
  try {
    const articleId = req.params.id;
    const updatedArticle = await updateArticle(articleId, req.body);
    if (!updatedArticle) {
      res.status(404).json({ error: 'Article not found' }); // Removed return
    }
    res.json(updatedArticle);
  } catch (error) {
    next(error);
  }
});

router.delete('/:id', isAuthenticated, requireAdminRole, async (req, res, next): Promise<void> => {
  try {
    const articleId = req.params.id;
    const deletedArticle = await deleteArticle(articleId);
    if (!deletedArticle) {
      res.status(404).json({ error: 'Article not found' }); // Removed return
    }
    res.json({ message: 'Article deleted successfully' });
  } catch (error) {
    next(error);
  }
});

export default router;
