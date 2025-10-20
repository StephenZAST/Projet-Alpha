"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const offer_controller_1 = require("../controllers/offer.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const offerValidation_middleware_1 = require("../middleware/offerValidation.middleware");
const validate_middleware_1 = require("../middleware/validate.middleware");
const router = express_1.default.Router();
router.use(auth_middleware_1.authenticateToken);
// Routes spécifiques AVANT les routes avec paramètres
router.get('/available', offer_controller_1.OfferController.getAvailableOffers);
router.get('/my-subscriptions', offer_controller_1.OfferController.getUserSubscriptions);
// Route admin pour lister toutes les offres (AVANT /:offerId)
router.get('/', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), offer_controller_1.OfferController.getAllOffers);
// Admin only routes
router.post('/', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), offerValidation_middleware_1.createOfferValidation, validate_middleware_1.validate, offer_controller_1.OfferController.createOffer);
// Routes avec paramètres offerId
router.get('/:offerId', offer_controller_1.OfferController.getOfferById);
router.post('/:offerId/subscribe', offer_controller_1.OfferController.subscribeToOffer);
router.post('/:offerId/unsubscribe', offer_controller_1.OfferController.unsubscribeFromOffer);
router.get('/:offerId/subscribers', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), offer_controller_1.OfferController.getSubscribers);
router.patch('/:offerId', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), offerValidation_middleware_1.updateOfferValidation, validate_middleware_1.validate, offer_controller_1.OfferController.updateOffer);
router.delete('/:offerId', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), offer_controller_1.OfferController.deleteOffer);
router.patch('/:offerId/status', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), offer_controller_1.OfferController.toggleOfferStatus);
exports.default = router;
