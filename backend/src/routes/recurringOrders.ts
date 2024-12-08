import express from 'express';
import { recurringOrderController } from '../controllers/recurringOrderController';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { 
  validateCreateRecurringOrder,
  validateUpdateRecurringOrder,
  validateCancelRecurringOrder,
  validateGetRecurringOrders,
  validateProcessRecurringOrders
} from '../middleware/recurringOrderValidation';
import { UserRole } from '../models/user';

const router = express.Router();

router.post(
  '/',
  isAuthenticated,
  validateCreateRecurringOrder, // Apply validation directly
  recurringOrderController.createRecurringOrder
);

router.put(
  '/:id',
  isAuthenticated,
  validateUpdateRecurringOrder, // Apply validation directly
  recurringOrderController.updateRecurringOrder
);

router.post(
  '/:id/cancel',
  isAuthenticated,
  validateCancelRecurringOrder, // Apply validation directly
  recurringOrderController.cancelRecurringOrder
);

router.get(
  '/',
  isAuthenticated,
  validateGetRecurringOrders, // Apply validation directly
  recurringOrderController.getRecurringOrders
);

router.post(
  '/process',
  isAuthenticated,
  requireAdminRolePath([UserRole.SUPER_ADMIN]),
  validateProcessRecurringOrders, // Apply validation directly
  recurringOrderController.processRecurringOrders
);

export default router;
