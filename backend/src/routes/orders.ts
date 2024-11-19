import express from 'express';
import { OrderService } from '../services/orders';
import { authMiddleware, requireSuperAdmin } from '../middleware/auth';
import { validateRequest } from '../middleware/validateRequest';
import { 
  createOrderSchema, 
  updateOrderSchema,
  updateOrderStatusSchema 
} from '../validation/orders';
import { OrderStatus } from '../models/order';
import { AppError, errorCodes } from '../utils/errors';

const router = express.Router();
const orderService = new OrderService();

/**
 * @swagger
 * /api/orders:
 *   post:
 *     tags: [Orders]
 *     summary: Create a new order
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateOrderRequest'
 */
router.post(
  '/',
  authMiddleware,
  validateRequest(createOrderSchema),
  async (req, res) => {
    try {
      const userId = req.user!.uid;
      const order = await orderService.createOrder({
        ...req.body,
        userId
      });
      res.status(201).json(order);
    } catch (error) {
      if (error instanceof AppError) {
        res.status(error.statusCode).json({ message: error.message, code: error.errorCode });
      } else {
        res.status(500).json({ message: 'Internal server error' });
      }
    }
  }
);

/**
 * @swagger
 * /api/orders:
 *   get:
 *     tags: [Orders]
 *     summary: Get user orders with pagination and filters
 *     security:
 *       - bearerAuth: []
 */
router.get('/', authMiddleware, async (req, res) => {
  try {
    const userId = req.user!.uid;
    const { 
      page = 1, 
      limit = 10, 
      status, 
      startDate, 
      endDate,
      sortBy = 'createdAt',
      sortOrder = 'desc'
    } = req.query;

    const orders = await orderService.getOrdersByUser(userId, {
      page: Number(page),
      limit: Number(limit),
      status: status as OrderStatus,
      startDate: startDate ? new Date(startDate as string) : undefined,
      endDate: endDate ? new Date(endDate as string) : undefined,
      sortBy: sortBy as string,
      sortOrder: sortOrder as 'asc' | 'desc'
    });

    res.json(orders);
  } catch (error) {
    if (error instanceof AppError) {
      res.status(error.statusCode).json({ message: error.message, code: error.errorCode });
    } else {
      res.status(500).json({ message: 'Internal server error' });
    }
  }
});

/**
 * @swagger
 * /api/orders/{id}:
 *   get:
 *     tags: [Orders]
 *     summary: Get order by ID
 *     security:
 *       - bearerAuth: []
 */
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const userId = req.user!.uid;
    const order = await orderService.getOrderById(req.params.id, userId);
    res.json(order);
  } catch (error) {
    if (error instanceof AppError) {
      res.status(error.statusCode).json({ message: error.message, code: error.errorCode });
    } else {
      res.status(500).json({ message: 'Internal server error' });
    }
  }
});

/**
 * @swagger
 * /api/orders/{id}:
 *   put:
 *     tags: [Orders]
 *     summary: Update order details
 *     security:
 *       - bearerAuth: []
 */
router.put('/:id',
  authMiddleware,
  validateRequest(updateOrderSchema),
  async (req, res) => {
    try {
      const userId = req.user!.uid;
      const order = await orderService.updateOrder(req.params.id, userId, req.body);
      res.json(order);
    } catch (error) {
      if (error instanceof AppError) {
        res.status(error.statusCode).json({ message: error.message, code: error.errorCode });
      } else {
        res.status(500).json({ message: 'Internal server error' });
      }
    }
});

/**
 * @swagger
 * /api/orders/{id}/status:
 *   patch:
 *     tags: [Orders]
 *     summary: Update order status
 *     security:
 *       - bearerAuth: []
 */
router.patch('/:id/status',
  authMiddleware,
  validateRequest(updateOrderStatusSchema),
  async (req, res) => {
    try {
      const userId = req.user!.uid;
      const { status } = req.body;
      const order = await orderService.updateOrderStatus(req.params.id, status, userId);
      res.json(order);
    } catch (error) {
      if (error instanceof AppError) {
        res.status(error.statusCode).json({ message: error.message, code: error.errorCode });
      } else {
        res.status(500).json({ message: 'Internal server error' });
      }
    }
});

/**
 * @swagger
 * /api/orders/{id}/cancel:
 *   post:
 *     tags: [Orders]
 *     summary: Cancel an order
 *     security:
 *       - bearerAuth: []
 */
router.post('/:id/cancel',
  authMiddleware,
  async (req, res) => {
    try {
      const userId = req.user!.uid;
      const order = await orderService.cancelOrder(req.params.id, userId);
      res.json(order);
    } catch (error) {
      if (error instanceof AppError) {
        res.status(error.statusCode).json({ message: error.message, code: error.errorCode });
      } else {
        res.status(500).json({ message: 'Internal server error' });
      }
    }
});

/**
 * @swagger
 * /api/orders/admin/all:
 *   get:
 *     tags: [Orders]
 *     summary: Get all orders (Admin only)
 *     security:
 *       - bearerAuth: []
 */
router.get('/admin/all',
  authMiddleware,
  requireSuperAdmin,
  async (req, res) => {
    try {
      const { 
        page = 1, 
        limit = 10, 
        status,
        userId,
        startDate,
        endDate,
        sortBy = 'createdAt',
        sortOrder = 'desc'
      } = req.query;

      const orders = await orderService.getAllOrders({
        page: Number(page),
        limit: Number(limit),
        status: status as OrderStatus,
        userId: userId as string,
        startDate: startDate ? new Date(startDate as string) : undefined,
        endDate: endDate ? new Date(endDate as string) : undefined,
        sortBy: sortBy as string,
        sortOrder: sortOrder as 'asc' | 'desc'
      });

      res.json(orders);
    } catch (error) {
      if (error instanceof AppError) {
        res.status(error.statusCode).json({ message: error.message, code: error.errorCode });
      } else {
        res.status(500).json({ message: 'Internal server error' });
      }
    }
});

export default router;
