const express = require('express');
const admin = require('firebase-admin');
const { createCategory, getCategories, updateCategory, deleteCategory } = require('../../src/services/categories');
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

// GET /categories - Get all categories
router.get('/', async (req, res) => {
  try {
    const categories = await getCategories();
    res.json(categories);
  } catch (error) {
    console.error('Error getting categories:', error);
    res.status(500).json({ error: 'Failed to retrieve categories' });
  }
});

// POST /categories - Create a new category (admin only)
router.post('/', isAuthenticated, requireAdminRole, async (req, res) => {
  try {
    const categoryData = req.body;
    const category = await createCategory(categoryData);
    res.status(201).json(category);
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error creating category:', error);
    res.status(500).json({ error: 'Failed to create category' });
  }
});

// PUT /categories/:id - Update an existing category (admin only)
router.put('/:id', isAuthenticated, requireAdminRole, async (req, res) => {
  try {
    const categoryId = req.params.id;
    const categoryData = req.body;
    const updatedCategory = await updateCategory(categoryId, categoryData);
    res.json(updatedCategory);
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error updating category:', error);
    res.status(500).json({ error: 'Failed to update category' });
  }
});

// DELETE /categories/:id - Delete a category (admin only)
router.delete('/:id', isAuthenticated, requireAdminRole, async (req, res) => {
  try {
    const categoryId = req.params.id;
    await deleteCategory(categoryId);
    res.status(204).send(); // No content
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error deleting category:', error);
    res.status(500).json({ error: 'Failed to delete category' });
  }
});

module.exports = router;
