// Removed Swagger comments
import express from 'express';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { validateRequest } from '../middleware/validateRequest';
import { 
  updateProfileSchema,
  updateAddressSchema,
  updatePreferencesSchema 
} from '../validation/userValidation';
import { UserService } from '../services/users';
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

export default router;
