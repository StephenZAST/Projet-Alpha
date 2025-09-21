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

// Routes admin (protection par rôle)
router.use('/admin', authorizeRoles(['ADMIN', 'SUPER_ADMIN']) as express.RequestHandler);

// Gestion des points de fidélité
router.get(
  '/admin/points',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.getAllLoyaltyPoints(req, res);
  })
);

router.get(
  '/admin/stats',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.getLoyaltyStats(req, res);
  })
);

router.get(
  '/admin/users/:userId/points',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.getLoyaltyPointsByUserId(req, res);
  })
);

// Gestion des transactions
router.get(
  '/admin/transactions',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.getPointTransactions(req, res);
  })
);

router.post(
  '/admin/users/:userId/add-points',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.addPointsToUser(req, res);
  })
);

router.post(
  '/admin/users/:userId/deduct-points',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.deductPointsFromUser(req, res);
  })
);

router.get(
  '/admin/users/:userId/history',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.getUserPointHistory(req, res);
  })
);

// Gestion des récompenses
router.get(
  '/admin/rewards',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.getAllRewards(req, res);
  })
);

router.get(
  '/admin/rewards/:rewardId',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.getRewardById(req, res);
  })
);

router.post(
  '/admin/rewards',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.createReward(req, res);
  })
);

router.patch(
  '/admin/rewards/:rewardId',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.updateReward(req, res);
  })
);

router.delete(
  '/admin/rewards/:rewardId',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.deleteReward(req, res);
  })
);

// Gestion des demandes de récompenses
router.get(
  '/admin/claims',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.getRewardClaims(req, res);
  })
);

router.get(
  '/admin/claims/pending',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.getPendingRewardClaims(req, res);
  })
);

router.patch(
  '/admin/claims/:claimId/approve',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.approveRewardClaim(req, res);
  })
);

router.patch(
  '/admin/claims/:claimId/reject',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.rejectRewardClaim(req, res);
  })
);

router.patch(
  '/admin/claims/:claimId/use',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.markRewardClaimAsUsed(req, res);
  })
);

// Utilitaires
router.post(
  '/calculate-points',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.calculateOrderPoints(req, res);
  })
);

router.post(
  '/process-order-points',
  asyncHandler(async (req: Request, res: Response) => {
    await LoyaltyController.processOrderPoints(req, res);
  })
);

export default router;
 