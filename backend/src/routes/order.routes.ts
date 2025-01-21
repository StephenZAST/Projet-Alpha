import express, { Request, Response, NextFunction } from 'express';
import { OrderController } from '../controllers/order.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { validateOrder } from '../middleware/validators';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

// Protection des routes avec authentification
router.use(authenticateToken as express.RequestHandler);

// Placer les routes spécifiques AVANT les routes avec paramètres
router.get(
  '/recent',
  authenticateToken as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await OrderController.getRecentOrders(req, res);
  })
);

router.get(
  '/by-status',
  authenticateToken as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await OrderController.getOrdersByStatus(req, res);
  })
);

// Routes client
router.post(
  '/',
  validateOrder as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await OrderController.createOrder(req, res);
  })
);

router.post(
  '/create-order',
  authenticateToken as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await OrderController.createOrder(req, res);
  })
);

router.get(
  '/my-orders',
  asyncHandler(async (req: Request, res: Response) => {
    await OrderController.getUserOrders(req, res);
  })
);

router.get(
  '/:orderId',
  asyncHandler(async (req: Request, res: Response) => {
    await OrderController.getOrderDetails(req, res);
  })
);

router.get(
  '/:orderId/invoice',
  authenticateToken as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await OrderController.generateInvoice(req, res);
  })
);

router.post(
  '/calculate-total',
  asyncHandler(async (req: Request, res: Response) => {
    await OrderController.calculateTotal(req, res);
  })
);

// Routes admin et livreur
router.patch(
  '/:orderId/status',
  authenticateToken as express.RequestHandler,
  authorizeRoles(['ADMIN', 'SUPER_ADMIN', 'DELIVERY']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await OrderController.updateOrderStatus(req, res);
  })
);

router.get(
  '/all-orders',
  authorizeRoles(['ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await OrderController.getAllOrders(req, res);
  })
);

router.delete(
  '/:orderId',
  authorizeRoles(['ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await OrderController.deleteOrder(req, res);
  })
);

export default router;
