const express = require('express');
const admin = require('firebase-admin');
const {
  createUser,
  registerCustomer,
  verifyEmail,
  requestPasswordReset,
  resetPassword,
  getUserByEmail,
  getUserById,
  getUserProfile,
  updateUser,
  deleteUser,
  UserRole,
  UserStatus,
  AccountCreationMethod,
} = require('../../src/services/users');
const { UserService } = require('../../src/services/users'); // Import UserService
const { validateRequest } = require('../../src/middleware/validateRequest');
const {
  updateProfileSchema,
  updateAddressSchema,
  updatePreferencesSchema,
  createUserSchema,
  emailVerificationSchema,
  passwordResetRequestSchema,
  passwordResetSchema,
} = require('../../src/validation/userValidation');
const { AppError } = require('../../src/utils/errors');

const db = admin.firestore();
const router = express.Router();
const userService = new UserService(); // Create an instance of UserService

// Middleware to check if the user is authenticated
const isAuthenticated = (req, res, next) => {
  const idToken = req.headers.authorization?.split('Bearer ')[1];

  if (!idToken) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  admin
      .auth()
      .verifyIdToken(idToken)
      .then((decodedToken) => {
        req.user = decodedToken;
        next();
      })
      .catch((error) => {
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
router.post('/register', validateRequest(createUserSchema), async (req, res) => {
  try {
    const user = await registerCustomer(req.body, AccountCreationMethod.SELF_REGISTRATION);
    res.status(201).json(user);
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error registering user:', error);
    res.status(500).json({ error: 'Failed to register user' });
  }
});

router.post('/verify-email', validateRequest(emailVerificationSchema), async (req, res) => {
  try {
    await verifyEmail(req.body.token);
    res.json({ message: 'Email verified successfully' });
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error verifying email:', error);
    res.status(500).json({ error: 'Failed to verify email' });
  }
});

router.post('/forgot-password', validateRequest(passwordResetRequestSchema), async (req, res) => {
  try {
    await requestPasswordReset(req.body.email);
    res.json({ message: 'Password reset email sent' });
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error requesting password reset:', error);
    res.status(500).json({ error: 'Failed to request password reset' });
  }
});

router.post('/reset-password', validateRequest(passwordResetSchema), async (req, res) => {
  try {
    await resetPassword(req.body.token, req.body.newPassword);
    res.json({ message: 'Password reset successfully' });
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error resetting password:', error);
    res.status(500).json({ error: 'Failed to reset password' });
  }
});

// Protected routes
router.use(isAuthenticated);

// GET /users/profile
router.get('/profile', async (req, res) => {
  try {
    const profile = await getUserProfile(req.user.uid);
    res.json(profile);
  } catch (error) {
    console.error('Error fetching user profile:', error);
    res.status(500).json({ error: 'Failed to fetch user profile' });
  }
});

// PUT /users/profile
router.put('/profile', validateRequest(updateProfileSchema), async (req, res) => {
  try {
    const updatedProfile = await userService.updateProfile(req.user.uid, req.body);
    res.json(updatedProfile);
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error updating user profile:', error);
    res.status(500).json({ error: 'Failed to update user profile' });
  }
});

// PUT /users/address
router.put('/address', validateRequest(updateAddressSchema), async (req, res) => {
  try {
    const updatedAddress = await userService.updateAddress(req.user.uid, req.body);
    res.json(updatedAddress);
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error updating user address:', error);
    res.status(500).json({ error: 'Failed to update user address' });
  }
});

// PUT /users/preferences
router.put('/preferences', validateRequest(updatePreferencesSchema), async (req, res) => {
  try {
    const updatedPreferences = await userService.updatePreferences(req.user.uid, req.body);
    res.json(updatedPreferences);
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error updating user preferences:', error);
    res.status(500).json({ error: 'Failed to update user preferences' });
  }
});

// Admin-only routes
router.use(requireAdminRole);

// GET /users/:id
router.get('/:id', async (req, res) => {
  try {
    const user = await getUserById(req.params.id);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json(user);
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ error: 'Failed to fetch user' });
  }
});

// GET /users
router.get('/', async (req, res) => {
  try {
    const { page = 1, limit = 10, search } = req.query;
    const users = await userService.getUsers({
      page: Number(page),
      limit: Number(limit),
      search: search,
    });
    res.json(users);
  } catch (error) {
    console.error('Error fetching users:', error);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

// PUT /users/:id
router.put('/:id', async (req, res) => {
  try {
    const userId = req.params.id;
    const updates = req.body;
    const updatedUser = await updateUser(userId, updates);
    res.json(updatedUser);
  } catch (error) {
    console.error('Error updating user:', error);
    res.status(500).json({ error: 'Failed to update user' });
  }
});

// DELETE /users/:id
router.delete('/:id', async (req, res) => {
  try {
    const userId = req.params.id;
    await deleteUser(userId);
    res.status(204).send(); // No content
  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({ error: 'Failed to delete user' });
  }
});

module.exports = router;
