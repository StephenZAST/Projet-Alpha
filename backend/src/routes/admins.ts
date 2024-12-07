import express from 'express';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
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
    const requesterId = req.user!.id; // Assuming user ID is available in req.user after authentication
    const admins = await adminService.getAllAdmins(requesterId);
    res.json(admins);
  } catch (error) {
    next(error);
  }
};

const getAdminById = async (req: express.Request<{ id: string }>, res: express.Response, next: express.NextFunction) => {
  try {
    const requesterId = req.user!.id; // Assuming user ID is available in req.user after authentication
    const admin = await adminService.getAdminById(req.params.id, requesterId);
    res.json(admin);
  } catch (error) {
    next(error);
  }
};

const createAdmin = async (req: express.Request, res: express.Response, next: express.NextFunction) => {
  try {
    const creatorId = req.user!.id; // Assuming user ID is available in req.user after authentication
    const admin = await adminService.createAdmin(req.body, creatorId);
    res.status(201).json(admin);
  } catch (error) {
    next(error);
  }
};

const updateAdmin = async (req: express.Request<{ id: string }>, res: express.Response, next: express.NextFunction) => {
  try {
    const updaterId = req.user!.id; // Assuming user ID is available in req.user after authentication
    const updatedAdmin = await adminService.updateAdmin(req.params.id, req.body, updaterId);
    res.json(updatedAdmin);
  } catch (error) {
    next(error);
  }
};

const deleteAdmin = async (req: express.Request<{ id: string }>, res: express.Response, next: express.NextFunction) => {
  try {
    const deleterId = req.user!.id; // Assuming user ID is available in req.user after authentication
    await adminService.deleteAdmin(req.params.id, deleterId);
    res.json({ message: 'Admin deleted successfully' });
  } catch (error) {
    next(error);
  }
};

const updateAdminRole = async (req: express.Request<{ id: string }>, res: express.Response, next: express.NextFunction) => {
  try {
    const updaterId = req.user!.id; // Assuming user ID is available in req.user after authentication
    const updatedAdmin = await adminService.updateAdmin(req.params.id, req.body, updaterId);
    res.json(updatedAdmin);
  } catch (error) {
    next(error);
  }
};

// Routes using route handler functions
router.get('/', validateGetAdmins, getAdmins); 
router.get('/:id', validateGetAdminById, getAdminById); 
router.post('/', validateCreateAdmin, createAdmin); 
router.put('/:id', validateUpdateAdmin, updateAdmin); 
router.delete('/:id', validateDeleteAdmin, deleteAdmin); 
router.put('/:id/role', validateUpdateAdminRole, updateAdminRole); 

export default router;
