import { Router } from 'express';
import { validateRequest } from '../middleware/validateRequest';
import { 
  customerRegistrationSchema, 
  adminCustomerCreationSchema,
  passwordResetRequestSchema,
  passwordResetSchema,
  emailVerificationSchema 
} from '../validation/userValidation';
import { 
  registerCustomer, 
  verifyEmail, 
  requestPasswordReset, 
  resetPassword 
} from '../services/users';
import { AccountCreationMethod, UserRole } from '../models/user';
import { isAuthenticated } from '../middleware/auth';
import { hasRole } from '../middleware/rbac';

const router = Router();

// Public routes
router.post('/register', validateRequest(customerRegistrationSchema), async (req, res, next) => {
  try {
    const userData = req.body;
    const user = await registerCustomer(userData, AccountCreationMethod.SELF_REGISTRATION);
    res.status(201).json({
      message: 'Registration successful. Please check your email to verify your account.',
      user: {
        uid: user.uid,
        email: user.email,
        displayName: user.displayName
      }
    });
  } catch (error) {
    next(error);
  }
});

// Admin route to create customer account
router.post(
  '/admin/create-customer',
  isAuthenticated,
  hasRole([UserRole.SUPER_ADMIN, UserRole.SECRETAIRE]),
  validateRequest(adminCustomerCreationSchema),
  async (req, res, next) => {
    try {
      const userData = {
        ...req.body,
        createdBy: req.user.uid // From auth middleware
      };
      const user = await registerCustomer(userData, AccountCreationMethod.ADMIN_CREATED);
      res.status(201).json({
        message: 'Customer account created successfully',
        user: {
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          phoneNumber: user.phoneNumber
        }
      });
    } catch (error) {
      next(error);
    }
  }
);

// Email verification
router.post('/verify-email', validateRequest(emailVerificationSchema), async (req, res, next) => {
  try {
    await verifyEmail(req.body.token);
    res.json({ message: 'Email verified successfully' });
  } catch (error) {
    next(error);
  }
});

// Password reset request
router.post('/forgot-password', validateRequest(passwordResetRequestSchema), async (req, res, next) => {
  try {
    await requestPasswordReset(req.body.email);
    res.json({ message: 'Password reset instructions sent to your email' });
  } catch (error) {
    next(error);
  }
});

// Reset password with token
router.post('/reset-password', validateRequest(passwordResetSchema), async (req, res, next) => {
  try {
    const { token, newPassword } = req.body;
    await resetPassword(token, newPassword);
    res.json({ message: 'Password reset successful' });
  } catch (error) {
    next(error);
  }
});

// Affiliate registration
router.post('/register/affiliate/:code', validateRequest(customerRegistrationSchema), async (req, res, next) => {
  try {
    const userData = {
      ...req.body,
      affiliateCode: req.params.code
    };
    const user = await registerCustomer(userData, AccountCreationMethod.AFFILIATE_REFERRAL);
    res.status(201).json({
      message: 'Registration successful. Please check your email to verify your account.',
      user: {
        uid: user.uid,
        email: user.email,
        displayName: user.displayName
      }
    });
  } catch (error) {
    next(error);
  }
});

// Customer referral registration
router.post('/register/referral/:code', validateRequest(customerRegistrationSchema), async (req, res, next) => {
  try {
    const userData = {
      ...req.body,
      sponsorCode: req.params.code
    };
    const user = await registerCustomer(userData, AccountCreationMethod.CUSTOMER_REFERRAL);
    res.status(201).json({
      message: 'Registration successful. Please check your email to verify your account.',
      user: {
        uid: user.uid,
        email: user.email,
        displayName: user.displayName
      }
    });
  } catch (error) {
    next(error);
  }
});

export default router;
