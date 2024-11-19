import express from 'express';
import { OrderService } from '../services/orders';
import { authMiddleware } from '../middleware/auth';
import { validateRequest } from '../middleware/validateRequest';
import { createOrderSchema } from '../validation/orders';
import { OrderStatus } from '../models/order';
import { AppError, errorCodes } from '../utils/errors';

const router = express.Router();
const orderService = new OrderService();

// Créer une nouvelle commande
router.post(
  '/',
  authMiddleware,
  validateRequest(createOrderSchema),
  async (req, res) => {
    try {
      const order = await orderService.createOrder(req.body);
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

// Récupérer toutes les commandes d'un utilisateur
router.get('/', authMiddleware, async (req, res) => {
  try {
    const userId = req.user?.uid; // Check if req.user is defined
    if (!userId) {
      throw new AppError(401, 'User ID not found', errorCodes.UNAUTHORIZED);
    }
    const orders = await orderService.getOrdersByUser(userId);
    res.json(orders);
  } catch (error) {
    if (error instanceof AppError) {
      res.status(error.statusCode).json({ message: error.message, code: error.errorCode });
    } else {
      res.status(500).json({ message: 'Internal server error' });
    }
  }
});

// Récupérer une commande spécifique par son ID
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const orderId = req.params.id;
    const userId = req.user?.uid; // Check if req.user is defined
    if (!userId) {
      throw new AppError(401, 'User ID not found', errorCodes.UNAUTHORIZED);
    }
    const orders = await orderService.getOrdersByUser(userId);
    const order = orders.find(order => order.id === orderId);

    if (!order) {
      throw new AppError(404, 'Order not found', errorCodes.ORDER_NOT_FOUND);
    }

    res.json(order);
  } catch (error) {
    if (error instanceof AppError) {
      res.status(error.statusCode).json({ message: error.message, code: error.errorCode });
    } else {
      res.status(500).json({ message: 'Internal server error' });
    }
  }
});

// Mettre à jour le statut d'une commande
router.patch('/:id/status', authMiddleware, async (req, res) => {
  try {
    const orderId = req.params.id;
    const status = req.body.status as OrderStatus;

    if (!Object.values(OrderStatus).includes(status)) {
      throw new AppError(400, 'Invalid order status', errorCodes.INVALID_ORDER_STATUS);
    }

    const updatedOrder = await orderService.updateOrderStatus(orderId, status);
    res.json(updatedOrder);
  } catch (error) {
    if (error instanceof AppError) {
      res.status(error.statusCode).json({ message: error.message, code: error.errorCode });
    } else {
      res.status(500).json({ message: 'Internal server error' });
    }
  }
});

export default router;
