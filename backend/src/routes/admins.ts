import express, { Request, Response, NextFunction } from 'express';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { 
  validateCreateAdmin, 
  validateUpdateAdmin, 
  validateGetAdmin 
} from '../middleware/adminValidation';
import { AdminService } from '../services/adminService';
import { AppError } from '../utils/errors';
import { UserRole } from '../models/user';

const router = express.Router();

// Protect all routes
router.use(isAuthenticated as express.RequestHandler);
router.use(requireAdminRolePath([UserRole.SUPER_ADMIN]) as express.RequestHandler);

// Define route handler functions using .then()
const getAdmins = (req: Request, res: Response, next: NextFunction) => {
  AdminService.getAllAdmins().then((admins) => {
    res.status(200).json({ admins });
  }).catch((error) => {
    next(error);
  });
};

const getAdminById = (req: Request, res: Response, next: NextFunction) => {
  AdminService.getAdminById(req.params.id).then((admin) => {
    res.status(200).json({ admin });
  }).catch((error) => {
    next(error);
  });
};

const createAdmin = (req: Request, res: Response, next: NextFunction) => {
  AdminService.createAdmin(req.body).then((admin) => {
    res.status(201).json({ admin });
  }).catch((error) => {
    next(error);
  });
};

const updateAdmin = (req: Request, res: Response, next: NextFunction) => {
  AdminService.updateAdmin(req.params.id, req.body).then((updatedAdmin) => {
    res.status(200).json({ updatedAdmin });
  }).catch((error) => {
    next(error);
  });
};

const deleteAdmin = (req: Request, res: Response, next: NextFunction) => {
  AdminService.deleteAdmin(req.params.id).then(() => {
    res.status(200).json({ message: 'Admin deleted successfully' });
  }).catch((error) => {
    next(error);
  });
};

// Routes using route handler functions
router.get('/', validateGetAdmin, getAdmins); 
router.get('/:id', validateGetAdmin, getAdminById); 
router.post('/', validateCreateAdmin, createAdmin); 
router.put('/:id', validateUpdateAdmin, updateAdmin); 
router.delete('/:id', validateGetAdmin, deleteAdmin); 

export default router;
