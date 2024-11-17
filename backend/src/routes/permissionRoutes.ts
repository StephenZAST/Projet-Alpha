import express from 'express';
import { PermissionController } from '../controllers/permissionController';
import { authenticate, authorize } from '../middleware/auth';
import { AdminRole } from '../models/admin';

const router = express.Router();
const permissionController = new PermissionController();

// Protéger toutes les routes
router.use(authenticate);

// Routes accessibles uniquement au Super Admin Master
router.use(authorize([AdminRole.SUPER_ADMIN_MASTER]));

// Initialiser les permissions par défaut
router.post('/initialize', permissionController.initializePermissions);

// Obtenir la matrice des rôles
router.get('/matrix', permissionController.getRoleMatrix);

// Routes CRUD pour les permissions
router.get('/role/:role', permissionController.getPermissionsByRole);
router.get('/resource/:resource', permissionController.getResourcePermissions);
router.post('/', permissionController.addPermission);
router.put('/:role/:resource', permissionController.updatePermission);
router.delete('/:role/:resource', permissionController.removePermission);

export default router;
