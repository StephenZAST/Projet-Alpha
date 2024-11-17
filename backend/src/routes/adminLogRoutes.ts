import express from 'express';
import { AdminLogController } from '../controllers/adminLogController';
import { authenticateUser, requireAdminRole } from '../middleware/auth';
import { AdminRole } from '../models/admin';

const router = express.Router();
const adminLogController = new AdminLogController();

// Protect all routes with authentication
router.use(authenticateUser);

// Protect routes with role authorization
router.use(requireAdminRole([AdminRole.SUPER_ADMIN_MASTER, AdminRole.SUPER_ADMIN]));

// Get all logs with filters
router.get('/', adminLogController.getLogs);

// Get recent activity of an admin
router.get('/recent-activity', adminLogController.getRecentActivity);

// Get failed login attempts
router.get('/failed-attempts/:adminId', adminLogController.getFailedLoginAttempts);

export default router;
