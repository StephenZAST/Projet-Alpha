import express from 'express';
import { AppError, errorCodes } from '../utils/errors';
import { createAdmin, getAdmin, updateAdmin, deleteAdmin } from '../models/admin';
import { createToken, verifyToken } from '../utils/auth';
import { validateRequest } from '../middleware/validation';
import { validateCreateAdmin, validateGetAdmin, validateUpdateAdmin } from '../middleware/adminValidation';

const router = express.Router();

// Register a new admin
router.post('/register', validateCreateAdmin, async (req, res, next) => {
  try {
    const adminData = req.body;
    const admin = await createAdmin(adminData);

    if (admin) {
      const token = createToken({ id: admin.id, role: admin.role });
      res.status(201).json({ message: 'Admin registered successfully', admin, token });
    } else {
      throw new AppError(500, 'Failed to register admin', 'INTERNAL_SERVER_ERROR');
    }
  } catch (error) {
    next(error);
  }
});

// Login an admin
router.post('/login', validateGetAdmin, async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const admin = await getAdmin(email);

    if (admin && admin.password === password) {
      const token = createToken({ id: admin.id, role: admin.role });
      res.status(200).json({ message: 'Login successful', admin, token });
    } else {
      throw new AppError(401, 'Invalid credentials', 'UNAUTHORIZED');
    }
  } catch (error) {
    next(error);
  }
});

// Update admin
router.put('/:id', validateUpdateAdmin, async (req, res, next) => {
  try {
    const { id } = req.params;
    const adminData = req.body;
    const admin = await updateAdmin(id, adminData);

    if (admin) {
      res.status(200).json({ message: 'Admin updated successfully', admin });
    } else {
      throw new AppError(404, 'Admin not found', 'ADMIN_NOT_FOUND');
    }
  } catch (error) {
    next(error);
  }
});

// Delete admin
router.delete('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    await deleteAdmin(id);
    res.status(200).json({ message: 'Admin deleted successfully' });
  } catch (error) {
    next(error);
  }
});

export default router;
