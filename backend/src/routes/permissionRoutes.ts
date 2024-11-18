import express from 'express';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { PermissionController } from '../controllers/permissionController';

const router = express.Router();
const permissionController = new PermissionController();

// Protect all routes in this router with authentication and admin role
router.use(isAuthenticated);
router.use(requireAdminRole);

// Routes
router.get('/', permissionController.getAllPermissions);
router.get('/:id', permissionController.getPermissionById);
router.post('/', permissionController.createPermission);
router.put('/:id', permissionController.updatePermission);
router.delete('/:id', permissionController.deletePermission);

// Role-based permission routes
router.get('/role/:roleId', permissionController.getRolePermissions);
router.post('/role/:roleId', permissionController.assignPermissionToRole);
router.delete('/role/:roleId/:permissionId', permissionController.removePermissionFromRole);

export default router;
