import express from 'express';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { createCategory, getCategories, updateCategory, deleteCategory } from '../services/categories';
import { UserRole } from '../models/user';

const router = express.Router();

router.get('/', async (req, res, next): Promise<void> => {
  try {
    const categories = await getCategories();
    res.json(categories);
  } catch (error) {
    next(error);
  }
});

router.post('/', isAuthenticated, requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res, next): Promise<void> => {
  try {
    const category = await createCategory(req.body);
    res.status(201).json(category);
  } catch (error) {
    next(error);
  }
});

router.put('/:id', isAuthenticated, requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res, next): Promise<void> => {
  try {
    const categoryId = req.params.id;
    const updatedCategory = await updateCategory(categoryId, req.body);
    if (!updatedCategory) {
      res.status(404).json({ error: 'Category not found' }); // Removed return
    }
    res.json(updatedCategory);
  } catch (error) {
    next(error);
  }
});

router.delete('/:id', isAuthenticated, requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res, next): Promise<void> => {
  try {
    const categoryId = req.params.id;
    await deleteCategory(categoryId);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

export default router;
