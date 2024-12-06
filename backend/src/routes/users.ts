import express from 'express';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { validateRequest } from '../middleware/validateRequest';
import { 
  updateProfileSchema,
  updateAddressSchema,
  updatePreferencesSchema,
  emailVerificationSchema
} from '../validation/userValidation';
import { 
  createUserSchema,
  updateUserSchema,
  loginSchema,
  changePasswordSchema,
  resetPasswordSchema,
  searchUsersSchema,
  updateRoleSchema
} from '../validation/users'; // Import missing schemas from users.ts
import { UserService, createUser, verifyEmail, requestPasswordReset, resetPassword } from '../services/users';
import { AppError } from '../utils/errors';

const router = express.Router();
const userService = new UserService();

router.get('/profile', isAuthenticated, async (req, res, next) => {
  try {
    const profile = await userService.getUserProfile(req.user!.uid);
    res.json(profile);
  } catch (error) {
    next(error);
  }
});

router.put('/profile', 
  isAuthenticated, 
  validateRequest(updateProfileSchema),
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
  validateRequest(updateAddressSchema),
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
  validateRequest(updatePreferencesSchema),
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
  validateRequest(searchUsersSchema),
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
  validateRequest(searchUsersSchema),
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

router.post('/register', validateRequest(createUserSchema), async (req, res, next) => {
  try {
    const user = await createUser(req.body);
    res.status(201).json(user);
  } catch (error) {
    next(error);
  }
});

router.post('/login', validateRequest(loginSchema), async (req, res, next) => {
  try {
    // Implement login logic
    res.json({ message: 'Login successful' });
  } catch (error) {
    next(error);
  }
});

router.post('/change-password', 
  isAuthenticated, 
  validateRequest(changePasswordSchema), 
  async (req, res, next) => {
    try {
      // Implement change password logic
      res.json({ message: 'Password changed successfully' });
    } catch (error) {
      next(error);
    }
  }
);

router.post('/reset-password', validateRequest(resetPasswordSchema), async (req, res, next) => {
  try {
    await requestPasswordReset(req.body.email);
    res.json({ message: 'Password reset email sent' });
  } catch (error) {
    next(error);
  }
});

router.post('/verify-email', validateRequest(emailVerificationSchema), async (req, res, next) => {
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
  validateRequest(updateRoleSchema), 
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
