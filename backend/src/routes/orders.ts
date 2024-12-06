import express from 'express';
import { OrderService } from '../services/orders';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { validateRequest } from '../middleware/validateRequest';
import { 
  createOrderSchema, 
  updateOrderSchema,
  updateOrderStatusSchema,
  searchOrdersSchema,
  orderStatsSchema
} from '../validation/orders';
import { OrderStatus } from '../models/order';
import { AppError, errorCodes } from '../utils/errors';
import { Timestamp } from 'firebase-admin/firestore'; // Import Timestamp

const router = express.Router();
const orderService = new OrderService();

router.post(
  '/',
  isAuthenticated,
  validateRequest(createOrderSchema),
  async (req, res, next) => {
    try {
      const userId = req.user!.uid;
      const order = await orderService.createOrder({
        ...req.body,
        userId
      });
      res.status(201).json(order);
    } catch (error) {
      next(error);
    }
  }
);

router.get('/', isAuthenticated, async (req, res, next) => {
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
    next(error);
  }
});

router.get('/:id', isAuthenticated, async (req, res, next) => {
  try {
    const userId = req.user!.uid;
    const order = await orderService.getOrderById(req.params.id, userId);
    res.json(order);
  } catch (error) {
    next(error);
  }
});

router.put('/:id',
  isAuthenticated,
  validateRequest(updateOrderSchema),
  async (req, res, next) => {
    try {
      const userId = req.user!.uid;
      const order = await orderService.updateOrder(req.params.id, userId, req.body);
      res.json(order);
    } catch (error) {
      next(error);
    }
});

router.patch('/:id/status',
  isAuthenticated,
  validateRequest(updateOrderStatusSchema),
  async (req, res, next) => {
    try {
      const userId = req.user!.uid;
      const { status, deliveryPersonId } = req.body;
      const order = await orderService.updateOrderStatus(req.params.id, status, deliveryPersonId);
      res.json(order);
    } catch (error) {
      next(error);
    }
});

router.post('/:id/cancel',
  isAuthenticated,
  async (req, res, next) => {
    try {
      const userId = req.user!.uid;
      const order = await orderService.cancelOrder(req.params.id, userId);
      res.json(order);
    } catch (error) {
      next(error);
    }
});

router.get('/admin/all',
  isAuthenticated,
  requireAdminRole,
  validateRequest(searchOrdersSchema),
  async (req, res, next) => {
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
      next(error);
    }
});

router.get('/admin/stats',
  isAuthenticated,
  requireAdminRole,
  validateRequest(orderStatsSchema),
  async (req, res, next) => {
    try {
      const { startDate, endDate, zoneId, deliveryPersonId, groupBy } = req.query;
      const stats = await orderService.getOrderStatistics({
        zoneId: zoneId as string,
        startDate: startDate ? Timestamp.fromDate(new Date(startDate as string)) : undefined, // Convert to Timestamp
        endDate: endDate ? Timestamp.fromDate(new Date(endDate as string)) : undefined // Convert to Timestamp
      });
      res.json(stats);
    } catch (error) {
      next(error);
    }
  }
);

export default router;
