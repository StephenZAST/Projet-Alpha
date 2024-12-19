import express from 'express';
import { billingController } from '../controllers/billingController';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { validate } from '../middleware/validation';
import { createBillSchema, updateBillSchema, getBillsSchema, getBillByIdSchema } from '../validations/billing';
import { UserRole } from '../models/user';
import { User } from '../models/user';
import { Request, Response, NextFunction, RequestHandler } from 'express';

interface AuthenticatedRequest extends Request {
    user?: User;
}

const router = express.Router();

// Public routes
router.post('/create', isAuthenticated, validate(createBillSchema), billingController.createBill as RequestHandler);
router.put('/update/:id', isAuthenticated, validate(updateBillSchema), billingController.updateBill as RequestHandler);
router.get('/bills', isAuthenticated, validate(getBillsSchema), billingController.getAllBills as RequestHandler);
router.get('/:id', isAuthenticated, validate(getBillByIdSchema), billingController.getBillById as RequestHandler);
router.delete('/delete/:id', isAuthenticated, billingController.deleteBill as RequestHandler);

// Admin-specific routes
router.post('/generate', requireAdminRolePath([UserRole.SUPER_ADMIN]), billingController.generateInvoices as RequestHandler); // No validation needed for this route

export default router;
