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
var __rest = (this && this.__rest) || function (s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
        t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) {
            if (e.indexOf(p[i]) < 0 && Object.prototype.propertyIsEnumerable.call(s, p[i]))
                t[p[i]] = s[p[i]];
        }
    return t;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OfferService = void 0;
const client_1 = require("@prisma/client");
const types_1 = require("../models/types");
const notification_service_1 = require("./notification.service");
const prisma = new client_1.PrismaClient();
class OfferService {
    // Fonction utilitaire pour normaliser les dates
    static normalizeDate(dateInput) {
        if (!dateInput)
            return undefined;
        const dateStr = dateInput.toString();
        // Si la date ne contient pas de fuseau horaire, ajouter 'Z' pour UTC
        if (!dateStr.includes('Z') && !dateStr.includes('+') && !dateStr.includes('-', 10)) {
            return new Date(dateStr + 'Z');
        }
        return new Date(dateStr);
    }
    static createOffer(data) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // Normaliser les dates
                const startDate = this.normalizeDate(data.startDate);
                const endDate = this.normalizeDate(data.endDate);
                const offer = yield prisma.offers.create({
                    data: {
                        name: data.name,
                        description: data.description,
                        discountType: data.discountType,
                        discountValue: data.discountValue,
                        minPurchaseAmount: data.minPurchaseAmount,
                        maxDiscountAmount: data.maxDiscountAmount,
                        isCumulative: data.isCumulative,
                        startDate: startDate,
                        endDate: endDate,
                        is_active: true,
                        pointsRequired: data.pointsRequired,
                        created_at: new Date(),
                        updated_at: new Date(),
                        offer_articles: data.articleIds ? {
                            create: data.articleIds.map(articleId => ({
                                article_id: articleId
                            }))
                        } : undefined
                    },
                    include: {
                        offer_articles: {
                            include: {
                                articles: true
                            }
                        }
                    }
                });
                // Notify admins
                yield notification_service_1.NotificationService.sendNotification('ADMIN', types_1.NotificationType.OFFER_CREATED, {
                    offerId: offer.id,
                    offerName: offer.name
                });
                return this.formatOffer(offer);
            }
            catch (error) {
                console.error('[OfferService] Create offer error:', error);
                throw error;
            }
        });
    }
    static getAvailableOffers(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            const offers = yield prisma.offers.findMany({
                where: {
                    is_active: true,
                    startDate: { lte: new Date() },
                    endDate: { gte: new Date() }
                },
                include: {
                    offer_articles: {
                        include: {
                            articles: true
                        }
                    }
                }
            });
            return offers.map(offer => this.formatOffer(offer));
        });
    }
    static getOfferById(offerId) {
        return __awaiter(this, void 0, void 0, function* () {
            const offer = yield prisma.offers.findUnique({
                where: { id: offerId },
                include: {
                    offer_articles: {
                        include: {
                            articles: true
                        }
                    }
                }
            });
            if (!offer)
                throw new Error('Offer not found');
            return this.formatOffer(offer);
        });
    }
    static updateOffer(offerId, updateData) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { articleIds } = updateData, offerDetails = __rest(updateData, ["articleIds"]);
                // Mapper isActive vers is_active pour la base de données
                const dbData = Object.assign({}, offerDetails);
                if ('isActive' in dbData) {
                    dbData.is_active = dbData.isActive;
                    delete dbData.isActive;
                }
                // Normaliser les dates pour Prisma
                if (dbData.startDate) {
                    dbData.startDate = this.normalizeDate(dbData.startDate);
                }
                if (dbData.endDate) {
                    dbData.endDate = this.normalizeDate(dbData.endDate);
                }
                const updatedOffer = yield prisma.offers.update({
                    where: { id: offerId },
                    data: Object.assign(Object.assign({}, dbData), { updated_at: new Date(), offer_articles: articleIds ? {
                            deleteMany: {},
                            create: articleIds.map(articleId => ({
                                article_id: articleId
                            }))
                        } : undefined }),
                    include: {
                        offer_articles: {
                            include: {
                                articles: true
                            }
                        }
                    }
                });
                return this.formatOffer(updatedOffer);
            }
            catch (error) {
                console.error('[OfferService] Update offer error:', error);
                throw error;
            }
        });
    }
    static deleteOffer(offerId) {
        return __awaiter(this, void 0, void 0, function* () {
            yield prisma.offers.delete({
                where: { id: offerId }
            });
        });
    }
    static toggleOfferStatus(offerId, isActive) {
        return __awaiter(this, void 0, void 0, function* () {
            const updatedOffer = yield prisma.offers.update({
                where: { id: offerId },
                data: {
                    is_active: isActive,
                    updated_at: new Date()
                }
            });
            return this.formatOffer(updatedOffer);
        });
    }
    static subscribeToOffer(userId, offerId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const offer = yield prisma.offers.findFirst({
                    where: {
                        id: offerId,
                        is_active: true
                    }
                });
                if (!offer)
                    throw new Error('Offer not found or inactive');
                if (!offer.isCumulative) {
                    yield prisma.offer_subscriptions.updateMany({
                        where: { userId: userId },
                        data: {
                            status: 'INACTIVE',
                            updated_at: new Date()
                        }
                    });
                }
                const subscription = yield prisma.offer_subscriptions.create({
                    data: {
                        userId: userId,
                        offer_id: offerId,
                        status: 'ACTIVE',
                        subscribed_at: new Date(),
                        updated_at: new Date()
                    },
                    include: {
                        offers: true
                    }
                });
                yield notification_service_1.NotificationService.sendNotification(userId, types_1.NotificationType.OFFER_SUBSCRIBED, {
                    offerId,
                    offerName: offer.name
                });
                return this.formatSubscription(subscription);
            }
            catch (error) {
                console.error('[OfferService] Subscribe error:', error);
                throw error;
            }
        });
    }
    static getUserSubscriptions(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            const subscriptions = yield prisma.offer_subscriptions.findMany({
                where: {
                    userId: userId,
                    status: 'ACTIVE'
                },
                include: {
                    offers: true
                }
            });
            return subscriptions.map(subscription => this.formatSubscription(subscription));
        });
    }
    static getSubscribers(offerId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const subscriptions = yield prisma.offer_subscriptions.findMany({
                    where: {
                        offer_id: offerId,
                        status: 'ACTIVE'
                    },
                    include: {
                        users: true,
                        offers: true
                    }
                });
                return subscriptions
                    .filter(subscription => {
                    const offer = subscription.offers;
                    return subscription.users && subscription.userId && offer;
                })
                    .map(subscription => {
                    var _a, _b, _c;
                    return ({
                        id: subscription.id,
                        userId: subscription.userId,
                        offerId: (_a = subscription.offer_id) !== null && _a !== void 0 ? _a : '',
                        status: (_b = subscription.status) !== null && _b !== void 0 ? _b : 'ACTIVE',
                        subscribedAt: new Date(subscription.subscribed_at || new Date()),
                        updatedAt: new Date(subscription.updated_at || new Date()),
                        user: subscription.users ? {
                            id: subscription.users.id,
                            email: subscription.users.email,
                            firstName: subscription.users.first_name,
                            lastName: subscription.users.last_name,
                            phone: (_c = subscription.users.phone) !== null && _c !== void 0 ? _c : null
                        } : undefined,
                        offer: subscription.offers ? this.formatOffer(subscription.offers) : undefined
                    });
                });
            }
            catch (error) {
                console.error('[OfferService] Get subscribers error:', error);
                throw error;
            }
        });
    }
    static unsubscribeFromOffer(userId, offerId) {
        return __awaiter(this, void 0, void 0, function* () {
            yield prisma.offer_subscriptions.updateMany({
                where: {
                    userId: userId,
                    offer_id: offerId
                },
                data: {
                    status: 'INACTIVE',
                    updated_at: new Date()
                }
            });
        });
    }
    static calculateOrderDiscounts(userId, subtotal) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const subscriptions = yield prisma.offer_subscriptions.findMany({
                    where: {
                        userId: userId,
                        status: 'ACTIVE'
                    },
                    include: {
                        offers: true
                    }
                });
                let total = subtotal;
                const discounts = [];
                for (const sub of subscriptions) {
                    const offer = sub.offers;
                    if (!offer || !this.isOfferValid(offer, subtotal))
                        continue;
                    const discountAmount = this.calculateDiscountAmount(offer, total);
                    discounts.push({
                        offerId: offer.id,
                        amount: discountAmount
                    });
                    if (!offer.isCumulative)
                        break;
                    total -= discountAmount;
                }
                return {
                    subtotal,
                    discounts,
                    total: Math.max(0, total)
                };
            }
            catch (error) {
                console.error('[OfferService] Calculate discounts error:', error);
                throw error;
            }
        });
    }
    // Admin: liste toutes les offres
    static getAllOffers() {
        return __awaiter(this, void 0, void 0, function* () {
            const offers = yield prisma.offers.findMany({
                include: {
                    offer_articles: {
                        include: {
                            articles: true
                        }
                    }
                }
            });
            return offers.map(offer => this.formatOffer(offer));
        });
    }
    static isOfferValid(offer, subtotal) {
        if (!offer)
            return false;
        const now = new Date();
        return (offer.is_active &&
            new Date(offer.startDate) <= now &&
            new Date(offer.endDate) >= now &&
            (!offer.minPurchaseAmount || subtotal >= offer.minPurchaseAmount));
    }
    static calculateDiscountAmount(offer, total) {
        if (!offer)
            return 0;
        let amount = 0;
        if (offer.discountType === 'PERCENTAGE') {
            amount = (total * Number(offer.discountValue)) / 100;
        }
        else {
            amount = Number(offer.discountValue);
        }
        if (offer.maxDiscountAmount) {
            amount = Math.min(amount, Number(offer.maxDiscountAmount));
        }
        return amount;
    }
    static formatOffer(data) {
        var _a, _b, _c;
        if (!data)
            throw new Error('Invalid offer data');
        return {
            id: data.id,
            name: data.name,
            description: data.description,
            discountType: data.discountType,
            discountValue: Number(data.discountValue),
            minPurchaseAmount: data.minPurchaseAmount ? Number(data.minPurchaseAmount) : undefined,
            maxDiscountAmount: data.maxDiscountAmount ? Number(data.maxDiscountAmount) : undefined,
            isCumulative: (_a = data.isCumulative) !== null && _a !== void 0 ? _a : false,
            startDate: new Date(data.startDate || new Date()),
            endDate: new Date(data.endDate || new Date()),
            isActive: (_b = data.is_active) !== null && _b !== void 0 ? _b : false,
            pointsRequired: data.pointsRequired ? Number(data.pointsRequired) : undefined,
            createdAt: new Date(data.created_at),
            updatedAt: new Date(data.updated_at),
            articles: ((_c = data.offer_articles) === null || _c === void 0 ? void 0 : _c.map((oa) => ({
                id: oa.articles.id,
                name: oa.articles.name,
                description: oa.articles.description
            }))) || []
        };
    }
    static formatSubscription(data) {
        return {
            id: data.id,
            userId: data.userId,
            offerId: data.offer_id,
            status: data.status,
            subscribedAt: new Date(data.subscribed_at),
            updatedAt: new Date(data.updated_at),
            offer: data.offers ? this.formatOffer(data.offers) : undefined
        };
    }
}
exports.OfferService = OfferService;
