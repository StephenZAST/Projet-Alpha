import express from 'express';
import { createPermissionController } from '../controllers/permissionController';
import { getPermissionsController } from '../controllers/permissionController';
import { getPermissionByIdController } from '../controllers/permissionController';
import { updatePermissionController } from '../controllers/permissionController';
import { deletePermissionController } from '../controllers/permissionController';
import { initializeDefaultPermissionsController } from '../controllers/permissionController';
import { getPermissionsByRoleController } from '../controllers/permissionController';
import { addPermissionController } from '../controllers/permissionController';
import { removePermissionController } from '../controllers/permissionController';
import { getRoleMatrixController } from '../controllers/permissionController';
import { getResourcePermissionsController } from '../controllers/permissionController';
import { authenticateAdmin } from '../utils/auth';

const router = express.Router();

// Middleware to authenticate admin
router.use(authenticateAdmin);

// Create a new permission
router.post('/create', createPermissionController);

// Get all permissions
router.get('/all', getPermissionsController);

// Get a permission by ID
router.get('/:id', getPermissionByIdController);

// Update a permission
router.put('/:id', updatePermissionController);

// Delete a permission
router.delete('/:id', deletePermissionController);

// Initialize default permissions
router.post('/initialize', initializeDefaultPermissionsController);

// Get permissions by role
router.get('/role/:role', getPermissionsByRoleController);

// Add a new permission
router.post('/add', addPermissionController);

// Remove a permission
router.delete('/remove/:id', removePermissionController);

// Get role matrix
router.get('/roleMatrix', getRoleMatrixController);

// Get resource permissions
router.get('/resource/:resource', getResourcePermissionsController);

export default router;
