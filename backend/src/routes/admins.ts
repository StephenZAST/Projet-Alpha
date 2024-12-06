import express from 'express';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { validateRequest } from '../middleware/validateRequest';
import { 
  validateGetAdminById,
  validateGetAdmins,
  validateCreateAdmin,
  validateUpdateAdmin,
  validateDeleteAdmin,
  validateUpdateAdminRole
} from '../middleware/adminValidation';
import { AdminService } from '../services/adminService';
import { AppError } from '../utils/errors';

const router = express.Router();
const adminService = new AdminService();

// Protect all routes
router.use(isAuthenticated);
router.use(requireAdminRole);

// Define route handler functions using async/await
const getAdmins = async (req: express.Request, res: express.Response, next: express.NextFunction) => {
  try {
    const { page = 1, limit = 10, search } = req.query;
    const admins = await adminService.getAdmins({
      page: Number(page),
      limit: Number(limit),
      search: search as string
    });
    res.json(admins);
  } catch (error) {
    next(error);
  }
};

const getAdminById = async (req: express.Request<{ id: string }>, res: express.Response, next: express.NextFunction) => {
  try {
    const admin = await adminService.getAdminById(req.params.id);
    res.json(admin);
  } catch (error) {
    next(error);
  }
};

const createAdmin = async (req: express.Request, res: express.Response, next: express.NextFunction) => {
  try {
    const admin = await adminService.createAdmin(req.body);
    res.status(201).json(admin);
  } catch (error) {
    next(error);
  }
};

const updateAdmin = async (req: express.Request<{ id: string }>, res: express.Response, next: express.NextFunction) => {
  try {
    const updatedAdmin = await adminService.updateAdmin(req.params.id, req.body);
    res.json(updatedAdmin);
  } catch (error) {
    next(error);
  }
};

const deleteAdmin = async (req: express.Request<{ id: string }>, res: express.Response, next: express.NextFunction) => {
  try {
    await adminService.deleteAdmin(req.params.id);
    res.json({ message: 'Admin deleted successfully' });
  } catch (error) {
    next(error);
  }
};

const updateAdminRole = async (req: express.Request<{ id: string }>, res: express.Response, next: express.NextFunction) => {
  try {
    const updatedAdmin = await adminService.updateAdminRole(req.params.id, req.body.role);
    res.json(updatedAdmin);
  } catch (error) {
    next(error);
  }
};

// Routes using route handler functions
router.get('/', validateGetAdmins, getAdmins); // Apply validation directly
router.get('/:id', validateGetAdminById, getAdminById); // Apply validation directly
router.post('/', validateCreateAdmin, createAdmin); // Apply validation directly
router.put('/:id', validateUpdateAdmin, updateAdmin); // Apply validation directly
router.delete('/:id', validateDeleteAdmin, deleteAdmin); // Apply validation directly
router.put('/:id/role', validateUpdateAdminRole, updateAdminRole); // Apply validation directly

export default router;
