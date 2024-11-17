import express from 'express';
import { AdminController } from '../controllers/adminController';
import { authenticateUser, requireRole } from '../middleware/auth';
import { AdminRole } from '../models/admin';
import { UserRole } from '../models/user';

const router = express.Router();
const adminController = new AdminController();

// Public routes
router.post('/login', adminController.login);

// Protected route for Master Admin creation (one-time use)
router.post('/master/create', adminController.createMasterAdmin);

// Protected routes requiring authentication
router.use(authenticateUser);

// Routes for Super Admin Master and Super Admin
router.use(requireRole([AdminRole.SUPER_ADMIN_MASTER, AdminRole.SUPER_ADMIN] as unknown as UserRole[]));
router.get('/all', adminController.getAllAdmins);
router.post('/create', adminController.createAdmin);

// Super Admin Master specific routes
router.use('/super-admin', requireRole([AdminRole.SUPER_ADMIN_MASTER] as unknown as UserRole[]));
router.post('/super-admin/create', adminController.createAdmin);
router.delete('/super-admin/:id', adminController.deleteAdmin);
router.put('/super-admin/:id', adminController.updateAdmin);

// Routes for all admins (view/modify their own profile)
router.get('/profile', adminController.getAdminById);
router.put('/profile', adminController.updateAdmin);

// Routes for managing other admins
router.get('/:id', adminController.getAdminById);
router.put('/:id', adminController.updateAdmin);
router.delete('/:id', adminController.deleteAdmin);
router.put('/:id/status', adminController.toggleAdminStatus);

export default router;