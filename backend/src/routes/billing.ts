import express from 'express';
import { billingController } from '../controllers/billingController';
import { isAuthenticated, requireAdminRolePath } from '../middleware/auth';
import { validateRequest } from '../middleware/validateRequest';
import { createBillSchema, updateBillSchema } from '../validation/billing';
import { UserRole } from '../models/user';

const router = express.Router();

// Protected routes requiring authentication
router.use(isAuthenticated);

// Public routes
router.post('/create', validateRequest(createBillSchema), billingController.createBill);
router.put('/update/:id', validateRequest(updateBillSchema), billingController.updateBill);
router.get('/bills', billingController.getAllBills);
router.get('/:id', billingController.getBillById);
router.delete('/delete/:id', billingController.deleteBill);

// Admin-specific routes
router.use(requireAdminRolePath([UserRole.SUPER_ADMIN]));
router.post('/generate', billingController.generateInvoices); // No validation needed for this route

export default router;
