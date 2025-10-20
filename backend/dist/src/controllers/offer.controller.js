"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OfferController = void 0;
const offer_service_1 = require("../services/offer.service");
class OfferController {
    // Client Endpoints
    static getAvailableOffers(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { userId } = req.user;
            const offers = yield offer_service_1.OfferService.getAvailableOffers(userId);
            return res.json({ success: true, data: offers });
        });
    }
    static subscribeToOffer(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { userId } = req.user;
            const { offerId } = req.params;
            yield offer_service_1.OfferService.subscribeToOffer(userId, offerId);
            return res.json({ success: true, message: 'Successfully subscribed to offer' });
        });
    }
    static unsubscribeFromOffer(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { userId } = req.user;
            const { offerId } = req.params;
            yield offer_service_1.OfferService.unsubscribeFromOffer(userId, offerId);
            return res.json({ success: true, message: 'Successfully unsubscribed from offer' });
        });
    }
    static getUserSubscriptions(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { userId } = req.user;
            const subscriptions = yield offer_service_1.OfferService.getUserSubscriptions(userId);
            return res.json({ success: true, data: subscriptions });
        });
    }
    // Admin Endpoints
    static createOffer(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const offer = yield offer_service_1.OfferService.createOffer(req.body);
            return res.status(201).json({ success: true, data: offer });
        });
    }
    static updateOffer(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { offerId } = req.params;
                const offer = yield offer_service_1.OfferService.updateOffer(offerId, req.body);
                return res.json({ success: true, data: offer });
            }
            catch (error) {
                console.error('[OfferController] updateOffer error:', error);
                return res.status(500).json({
                    success: false,
                    error: 'Failed to update offer',
                    message: error instanceof Error ? error.message : 'Unknown error'
                });
            }
        });
    }
    static getSubscribers(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { offerId } = req.params;
            const subscribers = yield offer_service_1.OfferService.getSubscribers(offerId);
            return res.json({ success: true, data: subscribers });
        });
    }
    static deleteOffer(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { offerId } = req.params;
            yield offer_service_1.OfferService.deleteOffer(offerId);
            return res.json({ success: true, message: 'Offer deleted successfully' });
        });
    }
    static getOfferById(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { offerId } = req.params;
            const offer = yield offer_service_1.OfferService.getOfferById(offerId);
            return res.json({ success: true, data: offer });
        });
    }
    static toggleOfferStatus(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { offerId } = req.params;
            const { isActive } = req.body;
            if (typeof isActive !== 'boolean') {
                return res.status(400).json({ error: 'isActive must be a boolean' });
            }
            const offer = yield offer_service_1.OfferService.toggleOfferStatus(offerId, isActive);
            return res.json({ success: true, data: offer });
        });
    }
    // Admin: liste toutes les offres
    static getAllOffers(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const offers = yield offer_service_1.OfferService.getAllOffers();
            return res.json({ success: true, data: offers });
        });
    }
}
exports.OfferController = OfferController;
