import express from 'express';
import { BillingController } from '../controllers/billingController';
import { isAuthenticated, requireAdminRole } from '../middleware/auth';
import { validateRequest } from '../middleware/validateRequest';
import { 
  validateCreateInvoice, 
  validateUpdateInvoice, 
  validateGetInvoices, 
  validateGetInvoiceById, 
  validateDeleteInvoice 
} from '../middleware/billingValidation';

const router = express.Router();
const billingController = new BillingController();

// Public routes
router.post('/create', validateCreateInvoice, billingController.createInvoice); // Apply validation directly
router.put('/update/:id', validateUpdateInvoice, billingController.updateInvoice); // Apply validation directly
router.get('/all', validateGetInvoices, billingController.getAllInvoices); // Apply validation directly
router.get('/:id', validateGetInvoiceById, billingController.getInvoiceById); // Apply validation directly
router.delete('/delete/:id', validateDeleteInvoice, billingController.deleteInvoice); // Apply validation directly

// Protected routes requiring authentication
router.use(isAuthenticated);

// Admin-specific routes
router.use(requireAdminRole);
router.post('/generate', billingController.generateInvoices); // No validation needed for this route

export default router;
