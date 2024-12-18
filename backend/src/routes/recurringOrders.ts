import express, { Request, Response, NextFunction } from 'express';
import { recurringOrderController } from '../controllers/recurringOrderController';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { 
  validateCreateRecurringOrder,
  validateUpdateRecurringOrder,
  validateCancelRecurringOrder,
  validateGetRecurringOrders,
  validateProcessRecurringOrders
} from '../middleware/recurringOrderValidation';
import { UserRole, User } from '../models/user';

interface AuthenticatedRequest extends Request {
  user?: User;
}

const router = express.Router();

router.post(
  '/',
  isAuthenticated,
  validateCreateRecurringOrder,
  (req: AuthenticatedRequest, res: Response, next: NextFunction) => recurringOrderController.createRecurringOrder(req, res, next)
);

router.put(
  '/:id',
  isAuthenticated,
  validateUpdateRecurringOrder,
  (req: AuthenticatedRequest, res: Response, next: NextFunction) => recurringOrderController.updateRecurringOrder(req, res, next)
);

router.post(
  '/:id/cancel',
  isAuthenticated,
  validateCancelRecurringOrder,
  (req: AuthenticatedRequest, res: Response, next: NextFunction) => recurringOrderController.cancelRecurringOrder(req, res, next)
);

router.get(
  '/',
  isAuthenticated,
  validateGetRecurringOrders,
  (req: AuthenticatedRequest, res: Response, next: NextFunction) => recurringOrderController.getRecurringOrders(req, res, next)
);

router.post(
  '/process',
  isAuthenticated,
  requireAdminRolePath([UserRole.SUPER_ADMIN]),
  validateProcessRecurringOrders,
  (req: Request, res: Response, next: NextFunction) => recurringOrderController.processRecurringOrders(req, res, next)
);

export default router;
