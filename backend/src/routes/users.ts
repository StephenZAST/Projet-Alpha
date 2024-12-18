import express from 'express';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
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
import { UserRole, User } from '../models/user';
import { Request, Response, NextFunction } from 'express';

interface AuthenticatedRequest extends Request {
  user?: User;
}

const router = express.Router();
const userService = new UserService();

router.get('/profile', isAuthenticated, validateGetUserProfile, async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const profile = await userService.getUserProfile(req.user!.id);
    res.json(profile);
  } catch (error) {
    next(error);
  }
});

router.put('/profile', 
  isAuthenticated, 
  validateUpdateProfile,
  async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const updatedProfile = await userService.updateProfile(req.user!.id, req.body);
      res.json(updatedProfile);
    } catch (error) {
      next(error);
    }
});

router.put('/address',
  isAuthenticated,
  validateUpdateAddress,
  async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const updatedAddress = await userService.updateAddress(req.user!.id, req.body);
      res.json(updatedAddress);
    } catch (error) {
      next(error);
    }
});

router.put('/preferences',
  isAuthenticated,
  validateUpdatePreferences,
  async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const updatedPreferences = await userService.updatePreferences(req.user!.id, req.body);
      res.json(updatedPreferences);
    } catch (error) {
      next(error);
    }
});

router.get('/:id',
  isAuthenticated,
  requireAdminRolePath([UserRole.SUPER_ADMIN]),
  validateGetUserById,
  async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      const user = await userService.getUserById(req.params.id);
      res.json(user);
    } catch (error) {
      next(error);
    }
});

router.get('/',
  isAuthenticated,
  requireAdminRolePath([UserRole.SUPER_ADMIN]),
  validateGetUsers,
  async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
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

router.post('/register', validateCreateUser, async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const user = await createUser(req.body);
    res.status(201).json(user);
  } catch (error) {
    next(error);
  }
});

router.post('/login', validateLogin, async (req: Request, res: Response, next: NextFunction): Promise<void> => {
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
  async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      // Implement change password logic
      res.json({ message: 'Password changed successfully' });
    } catch (error) {
      next(error);
    }
  }
);

router.post('/reset-password', validateResetPassword, async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    await requestPasswordReset(req.body.email);
    res.json({ message: 'Password reset email sent' });
  } catch (error) {
    next(error);
  }
});

router.post('/verify-email', validateVerifyEmail, async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    await verifyEmail(req.body.token);
    res.json({ message: 'Email verified successfully' });
  } catch (error) {
    next(error);
  }
});

router.put('/:id/role', 
  isAuthenticated, 
  requireAdminRolePath([UserRole.SUPER_ADMIN]), 
  validateUpdateUserRole, 
  async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<void> => {
    try {
      // Implement update role logic
      res.json({ message: 'User role updated successfully' });
    } catch (error) {
      next(error);
    }
  }
);

export default router;
