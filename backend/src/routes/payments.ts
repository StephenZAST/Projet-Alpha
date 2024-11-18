import { Router } from 'express';
import { isAuthenticated } from '../middleware/auth';
import { validateRequest } from '../middleware/validateRequest';
import { paymentValidation } from '../validations/paymentValidation';
import { paymentController } from '../controllers/paymentController';

const router = Router();

/**
 * @swagger
 * /api/payments/methods:
 *   get:
 *     tags: [Payments]
 *     summary: Get user payment methods
 *     description: Retrieve saved payment methods for the authenticated user
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of payment methods
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   id:
 *                     type: string
 *                   type:
 *                     type: string
 *                     enum: [CARD, BANK_ACCOUNT]
 *                   last4:
 *                     type: string
 *                   brand:
 *                     type: string
 *                   expiryMonth:
 *                     type: integer
 *                   expiryYear:
 *                     type: integer
 *                   isDefault:
 *                     type: boolean
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get(
  '/methods',
  isAuthenticated,
  paymentController.getPaymentMethods
);

/**
 * @swagger
 * /api/payments/methods:
 *   post:
 *     tags: [Payments]
 *     summary: Add payment method
 *     description: Add a new payment method for the authenticated user
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - type
 *               - token
 *             properties:
 *               type:
 *                 type: string
 *                 enum: [CARD, BANK_ACCOUNT]
 *               token:
 *                 type: string
 *                 description: Payment method token from payment processor
 *               isDefault:
 *                 type: boolean
 *                 description: Set as default payment method
 *     responses:
 *       201:
 *         description: Payment method added successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                 message:
 *                   type: string
 *                   example: Payment method added successfully
 *       400:
 *         description: Invalid input
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post(
  '/methods',
  isAuthenticated,
  validateRequest(paymentValidation.addPaymentMethod),
  paymentController.addPaymentMethod
);

/**
 * @swagger
 * /api/payments/methods/{id}:
 *   delete:
 *     tags: [Payments]
 *     summary: Remove payment method
 *     description: Remove a saved payment method
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Payment method ID
 *     responses:
 *       200:
 *         description: Payment method removed successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Payment method removed successfully
 *       404:
 *         description: Payment method not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.delete(
  '/methods/:id',
  isAuthenticated,
  validateRequest(paymentValidation.removePaymentMethod),
  paymentController.removePaymentMethod
);

/**
 * @swagger
 * /api/payments/methods/{id}/default:
 *   put:
 *     tags: [Payments]
 *     summary: Set default payment method
 *     description: Set a payment method as default
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Payment method ID
 *     responses:
 *       200:
 *         description: Default payment method updated
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message:
 *                   type: string
 *                   example: Default payment method updated successfully
 *       404:
 *         description: Payment method not found
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.put(
  '/methods/:id/default',
  isAuthenticated,
  validateRequest(paymentValidation.setDefaultPaymentMethod),
  paymentController.setDefaultPaymentMethod
);

/**
 * @swagger
 * /api/payments/process:
 *   post:
 *     tags: [Payments]
 *     summary: Process payment
 *     description: Process a payment for an order
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - orderId
 *               - amount
 *               - currency
 *               - paymentMethodId
 *             properties:
 *               orderId:
 *                 type: string
 *               amount:
 *                 type: number
 *                 format: float
 *               currency:
 *                 type: string
 *                 enum: [USD, EUR, GBP]
 *               paymentMethodId:
 *                 type: string
 *               description:
 *                 type: string
 *     responses:
 *       200:
 *         description: Payment processed successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                 status:
 *                   type: string
 *                   enum: [SUCCEEDED, PENDING, FAILED]
 *                 message:
 *                   type: string
 *       400:
 *         description: Invalid input or payment failed
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post(
  '/process',
  isAuthenticated,
  validateRequest(paymentValidation.processPayment),
  paymentController.processPayment
);

/**
 * @swagger
 * /api/payments/history:
 *   get:
 *     tags: [Payments]
 *     summary: Get payment history
 *     description: Retrieve payment history for the authenticated user
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           minimum: 1
 *           default: 1
 *         description: Page number
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 100
 *           default: 10
 *         description: Number of items per page
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [SUCCEEDED, PENDING, FAILED]
 *         description: Filter by payment status
 *     responses:
 *       200:
 *         description: Payment history retrieved successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 payments:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: string
 *                       amount:
 *                         type: number
 *                         format: float
 *                       currency:
 *                         type: string
 *                       status:
 *                         type: string
 *                         enum: [SUCCEEDED, PENDING, FAILED]
 *                       createdAt:
 *                         type: string
 *                         format: date-time
 *                       orderId:
 *                         type: string
 *                       paymentMethod:
 *                         type: object
 *                         properties:
 *                           type:
 *                             type: string
 *                           last4:
 *                             type: string
 *                           brand:
 *                             type: string
 *                 pagination:
 *                   type: object
 *                   properties:
 *                     total:
 *                       type: integer
 *                     pages:
 *                       type: integer
 *                     current:
 *                       type: integer
 *                     limit:
 *                       type: integer
 *       401:
 *         description: Unauthorized
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.get(
  '/history',
  isAuthenticated,
  validateRequest(paymentValidation.getPaymentHistory),
  paymentController.getPaymentHistory
);

/**
 * @swagger
 * /api/payments/refund:
 *   post:
 *     tags: [Payments]
 *     summary: Process refund
 *     description: Process a refund for a payment
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - paymentId
 *             properties:
 *               paymentId:
 *                 type: string
 *               amount:
 *                 type: number
 *                 format: float
 *                 description: Amount to refund (partial refund if specified)
 *               reason:
 *                 type: string
 *                 enum: [REQUESTED_BY_CUSTOMER, DUPLICATE, FRAUDULENT]
 *     responses:
 *       200:
 *         description: Refund processed successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id:
 *                   type: string
 *                 status:
 *                   type: string
 *                   enum: [SUCCEEDED, PENDING, FAILED]
 *                 amount:
 *                   type: number
 *                   format: float
 *                 message:
 *                   type: string
 *       400:
 *         description: Invalid input or refund failed
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */
router.post(
  '/refund',
  isAuthenticated,
  validateRequest(paymentValidation.processRefund),
  paymentController.processRefund
);

export { router as paymentRoutes };
