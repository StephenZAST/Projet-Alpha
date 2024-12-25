import express from 'express';
import { OfferController } from '../controllers/offer.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { asyncHandler } from '../utils/asyncHandler';

const router = express.Router();

router.use(authenticateToken);

// Routes publiques (clients)
router.get(
  '/available',
  asyncHandler((req, res, next) => OfferController.getAvailableOffers(req, res))
);

router.get(
  '/:offerId',
  asyncHandler((req, res, next) => OfferController.getOfferById(req, res))
);

// Routes admin
router.use(authorizeRoles(['ADMIN', 'SUPER_ADMIN']));

router.post(
  '/',
  asyncHandler((req, res, next) => OfferController.createOffer(req, res))
);

router.put(
  '/:offerId',
  asyncHandler((req, res, next) => OfferController.updateOffer(req, res))
);

router.delete(
  '/:offerId',
  asyncHandler((req, res, next) => OfferController.deleteOffer(req, res))
);

router.patch(
  '/:offerId/status',
  asyncHandler((req, res, next) => OfferController.toggleOfferStatus(req, res))
);

export default router;
