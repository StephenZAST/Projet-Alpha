const express = require('express');
const admin = require('firebase-admin');
const { AdminService } = require('../../src/services/adminService');
const { AppError } = require('../../src/utils/errors');

const router = express.Router();
const adminService = new AdminService();

// Middleware to check if the user is authenticated
const isAuthenticated = (req, res, next) => {
  const idToken = req.headers.authorization?.split('Bearer ')[1];

  if (!idToken) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  admin.auth().verifyIdToken(idToken)
      .then(decodedToken => {
        req.user = decodedToken;
        next();
      })
      .catch(error => {
        console.error('Error verifying ID token:', error);
        res.status(401).json({ error: 'Unauthorized' });
      });
};

// Middleware to check if the user has the admin role
const requireAdminRole = (req, res, next) => {
  if (req.user?.role !== 'admin') {
    return res.status(403).json({ error: 'Forbidden' });
  }
  next();
};

// Public routes
router.post('/login', adminService.login);

// Protected route for Master Admin creation (one-time use)
router.post('/master/create', adminService.createMasterAdmin);

// Protected routes requiring authentication
router.use(isAuthenticated);

// Routes for Super Admin Master and Super Admin
router.use(requireAdminRole);
router.get('/all', adminService.getAllAdmins);
router.post('/create', adminService.createAdmin);

// Super Admin Master specific routes
// TODO: Implement proper role-based authorization
router.post('/super-admin/create', adminService.createAdmin);
router.delete('/super-admin/:id', adminService.deleteAdmin);
router.put('/super-admin/:id', adminService.updateAdmin);

// Routes for all admins (view/modify their own profile)
router.get('/profile', adminService.getAdminById);
router.put('/profile', adminService.updateAdmin);

// Routes for managing other admins
router.get('/:id', adminService.getAdminById);
router.put('/:id', adminService.updateAdmin);
router.delete('/:id', adminService.deleteAdmin);
router.put('/:id/status', adminService.toggleAdminStatus);

module.exports = router;
