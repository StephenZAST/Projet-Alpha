import express from 'express';
import { AdminController } from '../controllers/adminController';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { AdminRole } from '../models/admin';
import { UserRole } from '../models/user';
import { 
  validateCreateAdmin, 
  validateUpdateAdmin, 
  validateLogin, 
  validateToggleStatus 
} from '../middleware/adminValidation';

const router = express.Router();
const adminController = new AdminController();

// Public routes
router.post('/login', validateLogin, adminController.login); // Apply validation directly

// Protected route for Master Admin creation (one-time use)
router.post('/master/create', adminController.createMasterAdmin); // No validation needed for this route

// Protected routes requiring authentication
router.use(isAuthenticated);

// Routes for Super Admin Master and Super Admin
router.use(requireAdminRole);
router.get('/all', adminController.getAllAdmins);
router.post('/create', validateCreateAdmin, adminController.createAdmin); // Apply validation directly

// Super Admin Master specific routes
router.post('/super-admin/create', validateCreateAdmin, adminController.createAdmin); // Apply validation directly
router.delete('/super-admin/:id', adminController.deleteAdmin);
router.put('/super-admin/:id', validateUpdateAdmin, adminController.updateAdmin); // Apply validation directly

// Routes for all admins (view/modify their own profile)
router.get('/profile', adminController.getAdminById);
router.put('/profile', validateUpdateAdmin, adminController.updateAdmin); // Apply validation directly

// Routes for managing other admins
router.get('/:id', adminController.getAdminById);
router.put('/:id', validateUpdateAdmin, adminController.updateAdmin); // Apply validation directly
router.delete('/:id', adminController.deleteAdmin);
router.put('/:id/status', validateToggleStatus, adminController.toggleAdminStatus); // Apply validation directly

export default router;
