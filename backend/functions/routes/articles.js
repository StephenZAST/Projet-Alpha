const express = require('express');
const admin = require('firebase-admin');
const { createArticle, getArticles, updateArticle, deleteArticle } = require('../../src/services/articles');
const { validateArticleInput } = require('../../src/middleware/validation/index');
const { AppError } = require('../../src/utils/errors');

// eslint-disable-next-line no-unused-vars
const db = admin.firestore();
const router = express.Router();

// Middleware to check if the user is authenticated
const isAuthenticated = (req, res, next) => {
  const idToken = req.headers.authorization?.split('Bearer ')[1];

  if (!idToken) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  admin.auth().verifyIdToken(idToken)
      .then(decodedToken => {
        req.user = decodedToken;
        next();
      })
      .catch(error => {
        console.error('Error verifying ID token:', error);
        res.status(401).json({ error: 'Unauthorized' });
      });
};

// Middleware to check if the user has the admin role
const requireAdminRole = (req, res, next) => {
  if (req.user?.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }
  next();
};

// Public route - anyone can view articles
router.get('/', async (req, res) => {
  try {
    const articles = await getArticles();
    res.json(articles);
  } catch (error) {
    console.error('Error getting articles:', error);
    res.status(500).json({ error: 'Failed to retrieve articles' });
  }
});

// Protected admin routes
router.post('/', isAuthenticated, requireAdminRole, validateArticleInput, async (req, res) => {
  try {
    const article = await createArticle(req.body);
    if (!article) {
      return res.status(400).json({ error: 'Failed to create article' });
    }
    res.status(201).json(article);
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error creating article:', error);
    res.status(500).json({ error: 'Failed to create article' });
  }
});

router.put('/:id', isAuthenticated, requireAdminRole, validateArticleInput, async (req, res) => {
  try {
    const articleId = req.params.id;
    const updatedArticle = await updateArticle(articleId, req.body);
    if (!updatedArticle) {
      return res.status(404).json({ error: 'Article not found' });
    }
    res.json(updatedArticle);
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error updating article:', error);
    res.status(500).json({ error: 'Failed to update article' });
  }
});

router.delete('/:id', isAuthenticated, requireAdminRole, async (req, res) => {
  try {
    const articleId = req.params.id;
    const deleted = await deleteArticle(articleId);
    if (!deleted) {
      return res.status(404).json({ error: 'Article not found' });
    }
    res.json({ message: 'Article deleted successfully' });
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error deleting article:', error);
    res.status(500).json({ error: 'Failed to delete article' });
  }
});

module.exports = router;
