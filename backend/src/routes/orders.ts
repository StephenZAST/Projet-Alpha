import express from 'express';
import { OrderController } from '../controllers/orderController';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { 
  validateCreateOrder,
  validateGetOrders,
  validateGetOrderById,
  validateUpdateOrderStatus,
  validateAssignDeliveryPerson,
  validateUpdateOrder,
  validateCancelOrder,
  validateGetOrderHistory,
  validateRateOrder
} from '../middleware/orderValidation';

const router = express.Router();
const orderController = new OrderController();

// Protected routes requiring authentication
router.use(isAuthenticated);

// User-specific routes
router.post('/', validateCreateOrder, orderController.createOrder); // Apply validation directly
router.get('/history', validateGetOrderHistory, orderController.getOrderHistory); // Apply validation directly
router.post('/:id/rate', validateRateOrder, orderController.rateOrder); // Apply validation directly

// Admin-specific routes
router.use(requireAdminRole);
router.get('/', validateGetOrders, orderController.getOrders); // Apply validation directly
router.get('/:id', validateGetOrderById, orderController.getOrderById); // Apply validation directly
router.put('/:id/status', validateUpdateOrderStatus, orderController.updateOrderStatus); // Apply validation directly
router.put('/:id/assign', validateAssignDeliveryPerson, orderController.assignDeliveryPerson); // Apply validation directly
router.put('/:id', validateUpdateOrder, orderController.updateOrder); // Apply validation directly
router.post('/:id/cancel', validateCancelOrder, orderController.cancelOrder); // Apply validation directly

export default router;
