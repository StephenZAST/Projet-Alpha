import express, { Request, Response, NextFunction } from 'express';
import { LoyaltyController } from '../controllers/loyalty.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

// Protection des routes avec authentification
router.use(authenticateToken as express.RequestHandler);

// Routes client
router.post(
  '/earn-points',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.earnPoints(req, res);
  })
);

router.post(
  '/spend-points',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.spendPoints(req, res);
  })
);
 
router.get(
  '/points-balance',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.getPointsBalance(req, res);
  })
);

export default router;
 