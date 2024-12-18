import express from 'express';
import { OrderController } from '../controllers/orderController';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
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
import { UserRole, User } from '../models/user';
import { Request, Response, NextFunction } from 'express';

interface AuthenticatedRequest extends Request {
  user?: User;
}

const router = express.Router();
const orderController = new OrderController();

// Protected routes requiring authentication
router.use(isAuthenticated);

// User-specific routes
router.post('/', validateCreateOrder, (req: AuthenticatedRequest, res: Response, next: NextFunction) => orderController.createOrder(req, res, next));
router.get('/history', validateGetOrderHistory, (req: AuthenticatedRequest, res: Response, next: NextFunction) => orderController.getOrderHistory(req, res, next));
router.post('/:id/rate', validateRateOrder, (req: AuthenticatedRequest, res: Response, next: NextFunction) => orderController.rateOrder(req, res, next));

// Admin-specific routes
router.use(requireAdminRolePath([UserRole.SUPER_ADMIN]));
router.get('/', validateGetOrders, (req: AuthenticatedRequest, res: Response, next: NextFunction) => orderController.getOrders(req, res, next));
router.get('/:id', validateGetOrderById, (req: AuthenticatedRequest, res: Response, next: NextFunction) => orderController.getOrderById(req, res, next));
router.put('/:id/status', validateUpdateOrderStatus, (req: AuthenticatedRequest, res: Response, next: NextFunction) => orderController.updateOrderStatus(req, res, next));
router.put('/:id/assign', validateAssignDeliveryPerson, (req: AuthenticatedRequest, res: Response, next: NextFunction) => orderController.assignDeliveryPerson(req, res, next));
router.put('/:id', validateUpdateOrder, (req: AuthenticatedRequest, res: Response, next: NextFunction) => orderController.updateOrder(req, res, next));
router.post('/:id/cancel', validateCancelOrder, (req: AuthenticatedRequest, res: Response, next: NextFunction) => orderController.cancelOrder(req, res, next));

export default router;
