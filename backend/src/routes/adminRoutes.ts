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
import { AdminRole } from '../models/admin';
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
  loginAdmin(req, res, next).then((admin) => {
    if (admin) {
      res.status(200).json({ message: 'Login successful', admin });
    } else {
      res.status(401).json({ message: 'Invalid credentials' });
    }
  });
});

// Protected route for Master Admin creation
router.post('/master/create', (req, res, next) => {
  createMasterAdmin(req, res, next).then((admin) => {
    if (admin) {
      res.status(201).json({ message: 'Master Admin created successfully', admin });
    } else {
      res.status(500).json({ message: 'Failed to create Master Admin' });
    }
  });
});

// Protected routes requiring authentication
router.use(isAuthenticated as express.RequestHandler);

// Routes for Super Admin Master and Super Admin
router.use(requireAdminRolePath([UserRole.SUPER_ADMIN]) as express.RequestHandler);
router.get('/all', (req, res, next) => {
  getAllAdmins(req, res, next).then((admins) => {
    res.status(200).json({ admins });
  });
});
router.post('/create', validateCreateAdmin, (req, res, next) => {
  registerAdmin(req, res, next).then((admin) => {
    if (admin) {
      res.status(201).json({ message: 'Admin created successfully', admin });
    } else {
      res.status(500).json({ message: 'Failed to create admin' });
    }
  });
});

// Super Admin Master specific routes
router.post('/super-admin/create', validateCreateAdmin, (req, res, next) => {
  registerAdmin(req, res, next).then((admin) => {
    if (admin) {
      res.status(201).json({ message: 'Super Admin created successfully', admin });
    } else {
      res.status(500).json({ message: 'Failed to create Super Admin' });
    }
  });
}); 
router.delete('/super-admin/:id', (req, res, next) => {
  deleteAdmin(req, res, next).then(() => {
    res.status(200).json({ message: 'Super Admin deleted successfully' });
  });
});
router.put('/super-admin/:id', validateUpdateAdmin, (req, res, next) => {
  updateAdmin(req, res, next).then((admin) => {
    if (admin) {
      res.status(200).json({ message: 'Super Admin updated successfully', admin });
    } else {
      res.status(404).json({ message: 'Super Admin not found' });
    }
  });
}); 

// Routes for all admins (view/modify their own profile)
router.get('/profile', (req, res, next) => {
  getAdminById(req, res, next).then((admin) => {
    if (admin) {
      res.status(200).json({ admin });
    } else {
      res.status(404).json({ message: 'Admin not found' });
    }
  });
});
router.put('/profile', validateUpdateAdmin, (req, res, next) => {
  updateAdmin(req, res, next).then((admin) => {
    if (admin) {
      res.status(200).json({ message: 'Admin updated successfully', admin });
    } else {
      res.status(404).json({ message: 'Admin not found' });
    }
  });
}); 

// Routes for managing other admins
router.get('/:id', (req, res, next) => {
  getAdminById(req, res, next).then((admin) => {
    if (admin) {
      res.status(200).json({ admin });
    } else {
      res.status(404).json({ message: 'Admin not found' });
    }
  });
});
router.put('/:id', validateUpdateAdmin, (req, res, next) => {
  updateAdmin(req, res, next).then((admin) => {
    if (admin) {
      res.status(200).json({ message: 'Admin updated successfully', admin });
    } else {
      res.status(404).json({ message: 'Admin not found' });
    }
  });
}); 
router.delete('/:id', (req, res, next) => {
  deleteAdmin(req, res, next).then(() => {
    res.status(200).json({ message: 'Admin deleted successfully' });
  });
});
router.put('/:id/status', validateToggleStatus, (req, res, next) => {
  toggleAdminStatus(req, res, next).then((admin) => {
    if (admin) {
      res.status(200).json({ message: 'Admin status toggled successfully', admin });
    } else {
      res.status(404).json({ message: 'Admin not found' });
    }
  });
}); 

export default router;
