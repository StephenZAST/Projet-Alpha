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
  resetPassword,
  sendVerificationEmail
} from '../services/users';
import { AccountCreationMethod, UserRole } from '../models/user';
import { auth } from '../middleware/auth';
import { hasRole } from '../middleware/rbac';

const router = Router();

/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     tags: [Authentication]
 *     summary: Register a new user
 *     description: Create a new user account with the provided details
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *               - firstName
 *               - lastName
 *               - phone
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: user@example.com
 *               password:
 *                 type: string
 *                 format: password
 *                 minLength: 8
 *                 example: "********"
 *               firstName:
 *                 type: string
 *                 example: John
 *               lastName:
 *                 type: string
 *                 example: Doe
 *               phone:
 *                 type: string
 *                 example: "+1234567890"
 *               role:
 *                 type: string
 *                 enum: [CLIENT, AFFILIATE]
 *                 default: CLIENT
 *     responses:
 *       201:
 *         description: User successfully registered
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                 email:
 *                   type: string
 *                 token:
 *                   type: string
 *       400:
 *         description: Invalid input data
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
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

/**
 * @swagger
 * /api/auth/admin/create-customer:
 *   post:
 *     tags: [Authentication]
 *     summary: Create a new customer account as admin
 *     description: Create a new customer account with the provided details
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *               - firstName
 *               - lastName
 *               - phone
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: user@example.com
 *               password:
 *                 type: string
 *                 format: password
 *                 minLength: 8
 *                 example: "********"
 *               firstName:
 *                 type: string
 *                 example: John
 *               lastName:
 *                 type: string
 *                 example: Doe
 *               phone:
 *                 type: string
 *                 example: "+1234567890"
 *     responses:
 *       201:
 *         description: Customer account created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                 email:
 *                   type: string
 *                 token:
 *                   type: string
 *       400:
 *         description: Invalid input data
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post(
  '/admin/create-customer',
  auth,
  hasRole([UserRole.SUPER_ADMIN, UserRole.SECRETAIRE]),
  validateRequest(adminCustomerCreationSchema),
  async (req, res, next) => {
    try {
      if (!req.user) {
        throw new Error('User not authenticated');
      }
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
  });

/**
 * @swagger
 * /api/auth/verify-email:
 *   post:
 *     tags: [Authentication]
 *     summary: Verify email address
 *     description: Verify email address using verification token
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - token
 *             properties:
 *               token:
 *                 type: string
 *                 example: "verification-token"
 *     responses:
 *       200:
 *         description: Email verified successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Email verified successfully
 *       400:
 *         description: Invalid or expired token
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post('/verify-email', validateRequest(emailVerificationSchema), async (req, res, next) => {
  try {
    await verifyEmail(req.body.token);
    res.json({ message: 'Email verified successfully' });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/auth/test-email:
 *   post:
 *     tags: [Authentication]
 *     summary: Test email sending
 *     description: Send a test email to a specified email address
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: user@example.com
 *     responses:
 *       200:
 *         description: Test email sent successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Test email sent successfully
 *       500:
 *         description: Error sending test email
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post('/test-email', async (req, res) => {
  try {
    await sendVerificationEmail('alphalaundry.service1@gmail.com', 'test-token-123');
    res.status(200).json({ message: 'Test email sent successfully' });
  } catch (error) {
    console.error('Error sending test email:', error);
    res.status(500).json({ error: 'Failed to send test email' });
  }
});

/**
 * @swagger
 * /api/auth/forgot-password:
 *   post:
 *     tags: [Authentication]
 *     summary: Request password reset
 *     description: Send a password reset link to user's email
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: user@example.com
 *     responses:
 *       200:
 *         description: Password reset email sent
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Password reset instructions sent to your email
 *       404:
 *         description: User not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post('/forgot-password', validateRequest(passwordResetRequestSchema), async (req, res, next) => {
  try {
    await requestPasswordReset(req.body.email);
    res.json({ message: 'Password reset instructions sent to your email' });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/auth/reset-password:
 *   post:
 *     tags: [Authentication]
 *     summary: Reset password
 *     description: Reset user password using reset token
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - token
 *               - password
 *             properties:
 *               token:
 *                 type: string
 *               password:
 *                 type: string
 *                 format: password
 *                 minLength: 8
 *                 example: "********"
 *     responses:
 *       200:
 *         description: Password reset successful
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Password has been reset successfully
 *       400:
 *         description: Invalid or expired token
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post('/reset-password', validateRequest(passwordResetSchema), async (req, res, next) => {
  try {
    const { token, newPassword } = req.body;
    await resetPassword(token, newPassword);
    res.json({ message: 'Password reset successful' });
  } catch (error) {
    next(error);
  }
});

/**
 * @swagger
 * /api/auth/register/affiliate/{code}:
 *   post:
 *     tags: [Authentication]
 *     summary: Register as affiliate
 *     description: Register a new user account with affiliate code
 *     parameters:
 *       - in: path
 *         name: code
 *         required: true
 *         schema:
 *           type: string
 *         description: Affiliate code
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *               - firstName
 *               - lastName
 *               - phone
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: user@example.com
 *               password:
 *                 type: string
 *                 format: password
 *                 minLength: 8
 *                 example: "********"
 *               firstName:
 *                 type: string
 *                 example: John
 *               lastName:
 *                 type: string
 *                 example: Doe
 *               phone:
 *                 type: string
 *                 example: "+1234567890"
 *     responses:
 *       201:
 *         description: User successfully registered
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                 email:
 *                   type: string
 *                 token:
 *                   type: string
 *       400:
 *         description: Invalid input data
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
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

/**
 * @swagger
 * /api/auth/register/referral/{code}:
 *   post:
 *     tags: [Authentication]
 *     summary: Register as referral
 *     description: Register a new user account with referral code
 *     parameters:
 *       - in: path
 *         name: code
 *         required: true
 *         schema:
 *           type: string
 *         description: Referral code
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *               - firstName
 *               - lastName
 *               - phone
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *                 example: user@example.com
 *               password:
 *                 type: string
 *                 format: password
 *                 minLength: 8
 *                 example: "********"
 *               firstName:
 *                 type: string
 *                 example: John
 *               lastName:
 *                 type: string
 *                 example: Doe
 *               phone:
 *                 type: string
 *                 example: "+1234567890"
 *     responses:
 *       201:
 *         description: User successfully registered
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                 email:
 *                   type: string
 *                 token:
 *                   type: string
 *       400:
 *         description: Invalid input data
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
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
