import express from 'express';
import { validateRequest } from '../middleware/validateRequest';
import { recurringOrderValidation } from '../validations/recurringOrderValidation';
import { recurringOrderController } from '../controllers/recurringOrderController';
import { authenticateUser } from '../middleware/auth';
import { isAdmin } from '../middleware/adminAuth';

const router = express.Router();

/**
 * @swagger
 * /api/recurring-orders:
 *   post:
 *     tags: [Recurring Orders]
 *     summary: Create a new recurring order
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - frequency
 *               - baseOrder
 *             properties:
 *               frequency:
 *                 type: string
 *                 enum: [ONCE, WEEKLY, BIWEEKLY, MONTHLY]
 *               baseOrder:
 *                 type: object
 *                 properties:
 *                   items:
 *                     type: array
 *                     items:
 *                       type: object
 *                   address:
 *                     type: object
 *                   preferences:
 *                     type: object
 *     responses:
 *       201:
 *         description: Recurring order created successfully
 *       400:
 *         description: Invalid request data
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Server error
 */
router.post(
  '/',
  authenticateUser,
  validateRequest(recurringOrderValidation.create),
  recurringOrderController.createRecurringOrder
);

/**
 * @swagger
 * /api/recurring-orders/{id}:
 *   put:
 *     tags: [Recurring Orders]
 *     summary: Update a recurring order
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               frequency:
 *                 type: string
 *                 enum: [ONCE, WEEKLY, BIWEEKLY, MONTHLY]
 *               baseOrder:
 *                 type: object
 *               isActive:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Recurring order updated successfully
 *       400:
 *         description: Invalid request data
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Recurring order not found
 *       500:
 *         description: Server error
 */
router.put(
  '/:id',
  authenticateUser,
  validateRequest(recurringOrderValidation.params),
  validateRequest(recurringOrderValidation.update),
  recurringOrderController.updateRecurringOrder
);

/**
 * @swagger
 * /api/recurring-orders/{id}/cancel:
 *   post:
 *     tags: [Recurring Orders]
 *     summary: Cancel a recurring order
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Recurring order cancelled successfully
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Recurring order not found
 *       500:
 *         description: Server error
 */
router.post(
  '/:id/cancel',
  authenticateUser,
  validateRequest(recurringOrderValidation.params),
  recurringOrderController.cancelRecurringOrder
);

/**
 * @swagger
 * /api/recurring-orders:
 *   get:
 *     tags: [Recurring Orders]
 *     summary: Get all active recurring orders for the authenticated user
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of recurring orders
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 recurringOrders:
 *                   type: array
 *                   items:
 *                     type: object
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Server error
 */
router.get(
  '/',
  authenticateUser,
  recurringOrderController.getRecurringOrders
);

/**
 * @swagger
 * /api/recurring-orders/process:
 *   post:
 *     tags: [Recurring Orders]
 *     summary: Process all pending recurring orders (protected admin endpoint)
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Recurring orders processed successfully
 *       401:
 *         description: Unauthorized
 *       500:
 *         description: Server error
 */
router.post(
  '/process',
  authenticateUser,
  isAdmin,
  recurringOrderController.processRecurringOrders
);

export default router;
