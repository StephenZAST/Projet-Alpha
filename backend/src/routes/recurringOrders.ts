import express from 'express';
import { validateRequest } from '../middleware/validateRequest';
import { recurringOrderValidation } from '../validations/recurringOrderValidation';
import { recurringOrderController } from '../controllers/recurringOrderController';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';

const router = express.Router();

router.post(
  '/',
  isAuthenticated,
  validateRequest(recurringOrderValidation.create),
  recurringOrderController.createRecurringOrder
);

router.put(
  '/:id',
  isAuthenticated,
  validateRequest(recurringOrderValidation.params),
  validateRequest(recurringOrderValidation.update),
  recurringOrderController.updateRecurringOrder
);

router.post(
  '/:id/cancel',
  isAuthenticated,
  validateRequest(recurringOrderValidation.params),
  recurringOrderController.cancelRecurringOrder
);

router.get(
  '/',
  isAuthenticated,
  recurringOrderController.getRecurringOrders
);

router.post(
  '/process',
  isAuthenticated,
  requireAdminRole,
  recurringOrderController.processRecurringOrders
);

export default router;
