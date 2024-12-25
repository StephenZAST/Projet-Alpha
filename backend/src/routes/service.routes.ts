import express from 'express';
import { ServiceController } from '../controllers/service.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

// Public routes
router.post('/create', asyncHandler(ServiceController.createService));

// Authenticated routes
router.use(authenticateToken as express.RequestHandler);

// Admin routes
router.get('/all', authorizeRoles(['SUPER_ADMIN', 'ADMIN']) as express.RequestHandler, asyncHandler(ServiceController.getAllServices));
router.patch('/update/:serviceId', authorizeRoles(['SUPER_ADMIN', 'ADMIN']) as express.RequestHandler, asyncHandler(ServiceController.updateService));
router.delete('/delete/:serviceId', authorizeRoles(['SUPER_ADMIN', 'ADMIN']) as express.RequestHandler, asyncHandler(ServiceController.deleteService));

export default router;
