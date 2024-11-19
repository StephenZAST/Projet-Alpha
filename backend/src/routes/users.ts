import express from 'express';
import { authenticateUser, requireSuperAdmin } from '../middleware/auth';
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

/**
 * @swagger
 * /api/users/profile:
 *   get:
 *     tags: [Users]
 *     summary: Get user profile
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User profile retrieved successfully
 */
router.get('/profile', authenticateUser, async (req, res, next) => {
  try {
    const profile = await userService.getUserProfile(req.user!.uid);
    res.json(profile);
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/users/profile:
 *   put:
 *     tags: [Users]
 *     summary: Update user profile
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/UpdateProfileRequest'
 */
router.put('/profile', 
  authenticateUser, 
  validateRequest(updateProfileSchema),
  async (req, res, next) => {
    try {
      const updatedProfile = await userService.updateProfile(req.user!.uid, req.body);
      res.json(updatedProfile);
    } catch (error) {
      next(error);
    }
});

/**
 * @swagger
 * /api/users/address:
 *   put:
 *     tags: [Users]
 *     summary: Update user address
 *     security:
 *       - bearerAuth: []
 */
router.put('/address',
  authenticateUser,
  validateRequest(updateAddressSchema),
  async (req, res, next) => {
    try {
      const updatedAddress = await userService.updateAddress(req.user!.uid, req.body);
      res.json(updatedAddress);
    } catch (error) {
      next(error);
    }
});

/**
 * @swagger
 * /api/users/preferences:
 *   put:
 *     tags: [Users]
 *     summary: Update user preferences
 *     security:
 *       - bearerAuth: []
 */
router.put('/preferences',
  authenticateUser,
  validateRequest(updatePreferencesSchema),
  async (req, res, next) => {
    try {
      const updatedPreferences = await userService.updatePreferences(req.user!.uid, req.body);
      res.json(updatedPreferences);
    } catch (error) {
      next(error);
    }
});

/**
 * @swagger
 * /api/users/{id}:
 *   get:
 *     tags: [Users]
 *     summary: Get user by ID (Admin only)
 *     security:
 *       - bearerAuth: []
 */
router.get('/:id',
  authenticateUser,
  requireSuperAdmin,
  async (req, res, next) => {
    try {
      const user = await userService.getUserById(req.params.id);
      res.json(user);
    } catch (error) {
      next(error);
    }
});

/**
 * @swagger
 * /api/users:
 *   get:
 *     tags: [Users]
 *     summary: Get all users (Admin only)
 *     security:
 *       - bearerAuth: []
 */
router.get('/',
  authenticateUser,
  requireSuperAdmin,
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