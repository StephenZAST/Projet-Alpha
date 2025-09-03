import express from 'express';
import { OfferController } from '../controllers/offer.controller';
import { authenticateToken, authorizeRoles } from '../middleware/auth.middleware';
import { createOfferValidation, updateOfferValidation } from '../middleware/offerValidation.middleware';
import { validate } from '../middleware/validate.middleware'; 

const router = express.Router();

router.use(authenticateToken);

// Routes spécifiques AVANT les routes avec paramètres
router.get('/available', OfferController.getAvailableOffers);
router.get('/my-subscriptions', OfferController.getUserSubscriptions);

// Route admin pour lister toutes les offres (AVANT /:offerId)
router.get(
  '/',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  OfferController.getAllOffers
);

// Admin only routes
router.post(
  '/', 
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  createOfferValidation,
  validate,
  OfferController.createOffer
);

// Routes avec paramètres offerId
router.get('/:offerId', OfferController.getOfferById);
router.post('/:offerId/subscribe', OfferController.subscribeToOffer);
router.post('/:offerId/unsubscribe', OfferController.unsubscribeFromOffer);

router.get(
  '/:offerId/subscribers',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  OfferController.getSubscribers
);

router.patch(
  '/:offerId',
  authorizeRoles(['ADMIN', 'SUPER_ADMIN']),
  updateOfferValidation,
  validate,
  OfferController.updateOffer
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
