import express, { Request, Response, NextFunction } from 'express';
import { DeliveryController } from '../controllers/delivery.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler'; 

const router = express.Router();

// Protection des routes avec authentification
router.use(authenticateToken as express.RequestHandler);

// Routes livreur
router.get(
  '/pending-orders',
  authorizeRoles(['DELIVERY', 'ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await DeliveryController.getPendingOrders(req, res);
  })
);

router.get(
  '/assigned-orders',
  authorizeRoles(['DELIVERY', 'ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await DeliveryController.getAssignedOrders(req, res);
  })
);
 
router.patch(
  '/:orderId/status',
  authorizeRoles(['DELIVERY', 'SUPER_ADMIN', 'ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await DeliveryController.updateOrderStatus(req, res);
  })
);

router.get(
  '/collected-orders',
  authorizeRoles(['DELIVERY', 'ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await DeliveryController.getCOLLECTEDOrders(req, res);
  })
);

router.get(
  '/processing-orders',
  authorizeRoles(['DELIVERY', 'ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await DeliveryController.getPROCESSINGOrders(req, res);
  })
);

router.get(
  '/ready-orders',
  authorizeRoles(['DELIVERY', 'ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await DeliveryController.getREADYOrders(req, res);
  })
);

router.get(
  '/delivering-orders',
  authorizeRoles(['DELIVERY', 'ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await DeliveryController.getDELIVERINGOrders(req, res);
  })
);

router.get(
  '/delivered-orders',
  authorizeRoles(['DELIVERY', 'ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await DeliveryController.getDELIVEREDOrders(req, res);
  })
);

router.get(
  '/cancelled-orders',
  authorizeRoles(['DELIVERY', 'ADMIN', 'SUPER_ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await DeliveryController.getCANCELLEDOrders(req, res);
  })
);

export default router;
 