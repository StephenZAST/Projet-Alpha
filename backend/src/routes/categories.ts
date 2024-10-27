import express from 'express';
import { authenticateUser, requireAdmin } from '../middleware/auth';
import { createCategory, getCategories, updateCategory, deleteCategory } from '../services/categories';

const router = express.Router();

router.get('/', async (req, res, next) => {
  try {
    const categories = await getCategories();
    res.json(categories);
  } catch (error) {
    next(error);
  }
});

router.post('/', authenticateUser, requireAdmin, async (req, res, next) => {
  try {
    const category = await createCategory(req.body);
    res.status(201).json(category);
  } catch (error) {
    next(error);
  }
});

router.put('/:id', authenticateUser, requireAdmin, async (req, res, next) => {
  try {
    const categoryId = req.params.id;
    const updatedCategory = await updateCategory(categoryId, req.body);
    if (!updatedCategory) {
      return res.status(404).json({ error: 'Category not found' });
    }
    res.json(updatedCategory);
  } catch (error) {
    next(error);
  }
});

router.delete('/:id', authenticateUser, requireAdmin, async (req, res, next) => {
  try {
    const categoryId = req.params.id;
    await deleteCategory(categoryId);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

export default router;
