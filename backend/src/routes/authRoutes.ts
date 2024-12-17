import express from 'express';
import { AppError, errorCodes } from '../utils/errors';
import { registerAdmin, loginAdmin, updateAdmin, deleteAdmin, getAdminById } from '../controllers/adminController';
import { validateRequest } from '../middleware/validation';
import { validateCreateAdmin, validateGetAdmin, validateUpdateAdmin } from '../middleware/adminValidation';
import { authenticateAdmin } from '../authModules/adminAuth';
import { createToken } from '../authModules/tokenUtils';
import { registerWithSupabase, loginWithSupabase } from '../authModules/supabaseAuth';

const router = express.Router();

// Register a new admin with Supabase
router.post('/register', validateCreateAdmin, async (req, res, next) => {
  try {
    const adminData = req.body;
    const data = await registerWithSupabase(adminData);

    if (data) {
      const token = createToken({ id: data.user?.id || '', role: 'admin' });
      res.status(201).json({ message: 'Admin registered successfully', data, token });
    } else {
      throw new AppError(500, 'Failed to register admin', 'INTERNAL_SERVER_ERROR');
    }
  } catch (error) {
    next(error);
  }
});

// Login an admin with Supabase
router.post('/login', validateGetAdmin, async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const data = await loginWithSupabase({ email, password });

    if (data) {
      const token = createToken({ id: data.user?.id || '', role: 'admin' });
      res.status(200).json({ message: 'Login successful', data, token });
    } else {
      throw new AppError(401, 'Invalid credentials', 'UNAUTHORIZED');
    }
  } catch (error) {
    next(error);
  }
});

// Update admin
router.put('/:id', validateUpdateAdmin, authenticateAdmin, async (req, res, next) => {
  try {
    const { id } = req.params;
    const adminData = req.body;
    const admin = await updateAdmin(req, res, next);

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
router.delete('/:id', validateRequest, authenticateAdmin, async (req, res, next) => {
  try {
    const { id } = req.params;
    await deleteAdmin(req, res, next);
    res.status(200).json({ message: 'Admin deleted successfully' });
  } catch (error) {
    next(error);
  }
});

// Get admin by ID
router.get('/:id', validateGetAdmin, authenticateAdmin, async (req, res, next) => {
  try {
    const { id } = req.params;
    const admin = await getAdminById(req, res, next);

    if (!admin) {
      throw new AppError(404, 'Admin not found', 'ADMIN_NOT_FOUND');
    }

    res.status(200).json({ admin });
  } catch (error) {
    next(error);
  }
});

export default router;
