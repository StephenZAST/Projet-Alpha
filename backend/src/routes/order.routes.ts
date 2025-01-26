import express from 'express';
import { OrderController } from '../controllers/order.controller/index';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { validateOrder } from '../middleware/validators';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

// Ajouter des logs pour le debugging
router.use((req, res, next) => {
  console.log('Order Route Request:', {
    path: req.path,
    method: req.method,
    headers: req.headers,
    body: req.body,
    user: req.user
  });
  next();
});

// Protection des routes avec authentification
router.use(authenticateToken);

// Routes client
router.post(
  '/',
  validateOrder,
  asyncHandler(OrderController.createOrder)
);

router.get(
  '/my-orders',
  asyncHandler(OrderController.getUserOrders)
);

router.get(
  '/:orderId',
  asyncHandler(OrderController.getOrderDetails)
);

router.get(
  '/:orderId/invoice',
  asyncHandler(OrderController.generateInvoice)
);

router.post(
  '/calculate-total',
  asyncHandler(OrderController.calculateTotal)
);

// Routes récentes et statuts
router.get(
  '/recent',
  asyncHandler(OrderController.getRecentOrders)
);

router.get(
  '/by-status',
  asyncHandler(OrderController.getOrdersByStatus)
);

// Routes admin et livreur
router.patch(
  '/:orderId/status',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN', 'DELIVERY']),
  asyncHandler(OrderController.updateOrderStatus)
);

router.get(
  '/all',
  authorizeRoles(['ADMIN']),
  asyncHandler(OrderController.getAllOrders)
);

router.delete(
  '/:orderId',
  authorizeRoles(['ADMIN']),
  asyncHandler(OrderController.deleteOrder)
);

export default router;
