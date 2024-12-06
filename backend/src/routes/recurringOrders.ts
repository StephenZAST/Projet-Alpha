// Removed Swagger comments
import express from 'express';
import { validateRequest } from '../middleware/validateRequest';
import { recurringOrderValidation } from '../validations/recurringOrderValidation';
import { recurringOrderController } from '../controllers/recurringOrderController';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';

const router = express.Router();

router.post(
  '/',
  isAuthenticated,
  validateRequest(recurringOrderValidation.create as any),
  recurringOrderController.createRecurringOrder
);

// ... (rest of the code remains the same)
