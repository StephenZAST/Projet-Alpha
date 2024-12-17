import express from 'express';
import { billingController } from '../controllers/billingController';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { validate } from '../middleware/validation';
import { createBillSchema, updateBillSchema, getBillsSchema, getBillByIdSchema } from '../validations/billing';
import { UserRole } from '../models/user';

const router = express.Router();

// Protected routes requiring authentication
router.use(isAuthenticated);

// Public routes
router.post('/create', validate(createBillSchema), billingController.createBill);
router.put('/update/:id', validate(updateBillSchema), billingController.updateBill);
router.get('/bills', validate(getBillsSchema), billingController.getAllBills);
router.get('/:id', validate(getBillByIdSchema), billingController.getBillById);
router.delete('/delete/:id', billingController.deleteBill);

// Admin-specific routes
router.use(requireAdminRolePath([UserRole.SUPER_ADMIN]));
router.post('/generate', billingController.generateInvoices); // No validation needed for this route

export default router;
