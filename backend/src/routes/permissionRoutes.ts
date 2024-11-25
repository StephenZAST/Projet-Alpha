import express from 'express';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { PermissionController } from '../controllers/permissionController';

const router = express.Router();
const permissionController = new PermissionController();

// Protect all routes in this router with authentication and admin role
router.use(isAuthenticated);
router.use(requireAdminRole);

// Define route handler functions using async/await
const getAllPermissions = async (req: express.Request, res: express.Response, next: express.NextFunction) => {
  await permissionController.getAllPermissions(req, res, next); // Pass next
};
const getPermissionById = async (req: express.Request<{ id: string }>, res: express.Response, next: express.NextFunction) => {
  await permissionController.getPermissionById(req, res, next); // Pass next
};
const createPermission = async (req: express.Request, res: express.Response, next: express.NextFunction) => {
  await permissionController.createPermission(req, res, next); // Pass next
};
const updatePermission = async (req: express.Request<{ id: string }>, res: express.Response, next: express.NextFunction) => {
  await permissionController.updatePermission(req, res, next); // Pass next
};
const deletePermission = async (req: express.Request<{ id: string }>, res: express.Response, next: express.NextFunction) => {
  await permissionController.deletePermission(req, res, next); // Pass next
};
const getRolePermissions = async (req: express.Request<{ roleId: string }>, res: express.Response, next: express.NextFunction) => {
  await permissionController.getRolePermissions(req, res, next); // Pass next
};
const assignPermissionToRole = async (req: express.Request<{ roleId: string }>, res: express.Response, next: express.NextFunction) => {
  await permissionController.assignPermissionToRole(req, res, next); // Pass next
};
const removePermissionFromRole = async (req: express.Request<{ roleId: string, permissionId: string }>, res: express.Response, next: express.NextFunction) => {
  await permissionController.removePermissionFromRole(req, res, next); // Pass next
};

// Routes using route handler functions
router.get('/', getAllPermissions);
router.get('/:id', getPermissionById);
router.post('/', createPermission);
router.put('/:id', updatePermission);
router.delete('/:id', deletePermission);

// Role-based permission routes
router.get('/role/:roleId', getRolePermissions);
router.post('/role/:roleId', assignPermissionToRole);
router.delete('/role/:roleId/:permissionId', removePermissionFromRole);

export default router;
