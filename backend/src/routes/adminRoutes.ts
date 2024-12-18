import express from 'express';
import { 
  loginAdmin, 
  createMasterAdmin, 
  getAllAdmins, 
  registerAdmin, 
  getAdminById, 
  updateAdmin, 
  deleteAdmin, 
  toggleAdminStatus 
} from '../controllers/adminController';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { UserRole } from '../models/user';
import { 
  validateCreateAdmin, 
  validateUpdateAdmin, 
  validateLogin, 
  validateToggleStatus 
} from '../middleware/adminValidation';

const router = express.Router();

// Public routes
router.post('/login', validateLogin, (req, res, next) => {
  loginAdmin(req, res, next);
});

// Protected route for Master Admin creation
router.post('/master/create', (req, res, next) => {
  createMasterAdmin(req, res, next);
});

// Protected routes requiring authentication
router.use(isAuthenticated as express.RequestHandler);

// Routes for Super Admin Master and Super Admin
router.use(requireAdminRolePath([UserRole.SUPER_ADMIN]) as express.RequestHandler);
router.get('/all', (req, res, next) => {
  getAllAdmins(req, res, next);
});
router.post('/create', validateCreateAdmin, (req, res, next) => {
  registerAdmin(req, res, next);
});

// Super Admin Master specific routes
router.post('/super-admin/create', validateCreateAdmin, (req, res, next) => {
  registerAdmin(req, res, next);
}); 
router.delete('/super-admin/:id', (req, res, next) => {
  deleteAdmin(req, res, next);
});
router.put('/super-admin/:id', validateUpdateAdmin, (req, res, next) => {
  updateAdmin(req, res, next);
}); 

// Routes for all admins (view/modify their own profile)
router.get('/profile', (req, res, next) => {
  getAdminById(req, res, next);
});
router.put('/profile', validateUpdateAdmin, (req, res, next) => {
  updateAdmin(req, res, next);
}); 

// Routes for managing other admins
router.get('/:id', (req, res, next) => {
  getAdminById(req, res, next);
});
router.put('/:id', validateUpdateAdmin, (req, res, next) => {
  updateAdmin(req, res, next);
}); 
router.delete('/:id', (req, res, next) => {
  deleteAdmin(req, res, next);
});
router.put('/:id/status', validateToggleStatus, (req, res, next) => {
  toggleAdminStatus(req, res, next);
}); 

export default router;
