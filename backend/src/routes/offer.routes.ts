import express from 'express';
import { OfferController } from '../controllers/offer.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { createOfferValidation, updateOfferValidation } from '../middleware/offerValidation.middleware';
import { validate } from '../middleware/validate.middleware'; 

const router = express.Router();

router.use(authenticateToken);

// Routes without async handler wrapper since controller methods are already async
router.get('/available', OfferController.getAvailableOffers);
router.get('/my-subscriptions', OfferController.getUserSubscriptions);

// Protected routes (with offerId parameter)
router.get('/:offerId', OfferController.getOfferById);
router.post('/:offerId/subscribe', OfferController.subscribeToOffer);
router.post('/:offerId/unsubscribe', OfferController.unsubscribeFromOffer);

// Admin only routes
router.post(
  '/', 
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  createOfferValidation,
  validate,
  OfferController.createOffer
);

router.patch(
  '/:offerId',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  updateOfferValidation,
  validate,
  OfferController.updateOffer
);

router.get(
  '/:offerId/subscribers',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  OfferController.getSubscribers
);

router.delete(
  '/:offerId',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  OfferController.deleteOffer
);

router.patch(
  '/:offerId/status',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  OfferController.toggleOfferStatus
);

export default router;
