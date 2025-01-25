import express, { Request, Response, NextFunction } from 'express';
import { OrderItemController } from '../controllers/orderItem.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

// Protection des routes avec authentification
router.use(authenticateToken as express.RequestHandler);

// Routes admin
router.post(
  '/',
  authorizeRoles(['ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await OrderItemController.createOrderItem(req, res);
  })
);

router.get(
    '/:orderItemId',
    asyncHandler(async (req: Request, res: Response) => {
        await OrderItemController.getOrderItemById(req, res);
    })
);

router.get(
  '/order/:orderId',
  asyncHandler(async (req: Request, res: Response) => {
    await OrderItemController.getOrderItemsByOrderId(req, res);
  })
);

router.get(
  '/',
  asyncHandler(async (req: Request, res: Response) => {
    await OrderItemController.getAllOrderItems(req, res);
  })
);

router.patch(
  '/:orderItemId',
  authorizeRoles(['ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await OrderItemController.updateOrderItem(req, res);
  })
);

router.delete(
  '/:orderItemId',
  authorizeRoles(['ADMIN']) as express.RequestHandler,
  asyncHandler(async (req: Request, res: Response) => {
    await OrderItemController.deleteOrderItem(req, res);
  })
);

export default router;