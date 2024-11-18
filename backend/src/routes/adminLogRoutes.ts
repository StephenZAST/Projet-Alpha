import express from 'express';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { AdminLogController } from '../controllers/adminLogController';

const router = express.Router();
const adminLogController = new AdminLogController();

// Protect all routes in this router with authentication and admin role
router.use(isAuthenticated);
router.use(requireAdminRole);

// Routes
router.get('/', adminLogController.getLogs);
router.get('/:id', adminLogController.getLogById);
router.post('/', adminLogController.createLog);
router.put('/:id', adminLogController.updateLog);
router.delete('/:id', adminLogController.deleteLog);

export default router;
