import express from 'express';
import { billingController } from '../controllers/billingController';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { validate } from '../middleware/validation';
import { createBillSchema, updateBillSchema, getBillsSchema, getBillByIdSchema } from '../validations/billing';
import { UserRole } from '../models/user';

const router = express.Router();

// Public routes
router.post('/create', isAuthenticated, validate(createBillSchema), billingController.createBill);
router.put('/update/:id', isAuthenticated, validate(updateBillSchema), billingController.updateBill);
router.get('/bills', isAuthenticated, validate(getBillsSchema), billingController.getAllBills);
router.get('/:id', isAuthenticated, validate(getBillByIdSchema), billingController.getBillById);
router.delete('/delete/:id', isAuthenticated, billingController.deleteBill);

// Admin-specific routes
router.post('/generate', requireAdminRolePath([UserRole.SUPER_ADMIN]), billingController.generateInvoices); // No validation needed for this route

export default router;
