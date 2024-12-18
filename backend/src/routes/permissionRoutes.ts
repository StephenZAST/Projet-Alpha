import express from 'express';
import { createPermission, getPermissions, getPermissionById, updatePermission, deletePermission, initializeDefaultPermissions, getPermissionsByRole, addPermission, removePermission, getRoleMatrix, getResourcePermissions } from '../controllers/permissionController';

import { authenticateAdmin } from '../middleware/adminAuth';

const router = express.Router();

// Middleware to authenticate admin
router.use(authenticateAdmin);

// Create a new permission
router.post('/create', createPermission);

// Get all permissions
router.get('/all', getPermissions);

// Get a permission by ID
router.get('/:id', getPermissionById);

// Update a permission
router.put('/:id', updatePermission);

// Delete a permission
router.delete('/:id', deletePermission);

// Initialize default permissions
router.post('/initialize', initializeDefaultPermissions);

// Get permissions by role
router.get('/role/:role', getPermissionsByRole);

// Add a new permission
router.post('/add', addPermission);

// Remove a permission
router.delete('/remove/:id', removePermission);

// Get role matrix
router.get('/roleMatrix', getRoleMatrix);

// Get resource permissions
router.get('/resource/:resource', getResourcePermissions);

export default router;
