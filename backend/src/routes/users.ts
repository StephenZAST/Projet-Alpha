import express from 'express';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { 
  validateGetUserProfile,
  validateUpdateProfile,
  validateUpdateAddress,
  validateUpdatePreferences,
  validateGetUserById,
  validateGetUsers,
  validateCreateUser,
  validateLogin,
  validateChangePassword,
  validateResetPassword,
  validateVerifyEmail,
  validateUpdateUserRole
} from '../middleware/userValidation';
import { UserService, createUser, verifyEmail, requestPasswordReset, resetPassword } from '../services/users';

const router = express.Router();
const userService = new UserService();

router.get('/profile', isAuthenticated, validateGetUserProfile, async (req, res, next) => {
  try {
    const profile = await userService.getUserProfile(req.user!.uid);
    res.json(profile);
  } catch (error) {
    next(error);
  }
});

router.put('/profile', 
  isAuthenticated, 
  validateUpdateProfile,
  async (req, res, next) => {
    try {
      const updatedProfile = await userService.updateProfile(req.user!.uid, req.body);
      res.json(updatedProfile);
    } catch (error) {
      next(error);
    }
});

router.put('/address',
  isAuthenticated,
  validateUpdateAddress,
  async (req, res, next) => {
    try {
      const updatedAddress = await userService.updateAddress(req.user!.uid, req.body);
      res.json(updatedAddress);
    } catch (error) {
      next(error);
    }
});

router.put('/preferences',
  isAuthenticated,
  validateUpdatePreferences,
  async (req, res, next) => {
    try {
      const updatedPreferences = await userService.updatePreferences(req.user!.uid, req.body);
      res.json(updatedPreferences);
    } catch (error) {
      next(error);
    }
});

router.get('/:id',
  isAuthenticated,
  requireAdminRole,
  validateGetUserById,
  async (req, res, next) => {
    try {
      const user = await userService.getUserById(req.params.id);
      res.json(user);
    } catch (error) {
      next(error);
    }
});

router.get('/',
  isAuthenticated,
  requireAdminRole,
  validateGetUsers,
  async (req, res, next) => {
    try {
      const { page = 1, limit = 10, search } = req.query;
      const users = await userService.getUsers({
        page: Number(page),
        limit: Number(limit),
        search: search as string
      });
      res.json(users);
    } catch (error) {
      next(error);
    }
});

router.post('/register', validateCreateUser, async (req, res, next) => {
  try {
    const user = await createUser(req.body);
    res.status(201).json(user);
  } catch (error) {
    next(error);
  }
});

router.post('/login', validateLogin, async (req, res, next) => {
  try {
    // Implement login logic
    res.json({ message: 'Login successful' });
  } catch (error) {
    next(error);
  }
});

router.post('/change-password', 
  isAuthenticated, 
  validateChangePassword, 
  async (req, res, next) => {
    try {
      // Implement change password logic
      res.json({ message: 'Password changed successfully' });
    } catch (error) {
      next(error);
    }
  }
);

router.post('/reset-password', validateResetPassword, async (req, res, next) => {
  try {
    await requestPasswordReset(req.body.email);
    res.json({ message: 'Password reset email sent' });
  } catch (error) {
    next(error);
  }
});

router.post('/verify-email', validateVerifyEmail, async (req, res, next) => {
  try {
    await verifyEmail(req.body.token);
    res.json({ message: 'Email verified successfully' });
  } catch (error) {
    next(error);
  }
});

router.put('/:id/role', 
  isAuthenticated, 
  requireAdminRole, 
  validateUpdateUserRole, 
  async (req, res, next) => {
    try {
      // Implement update role logic
      res.json({ message: 'User role updated successfully' });
    } catch (error) {
      next(error);
    }
  }
);

export default router;
