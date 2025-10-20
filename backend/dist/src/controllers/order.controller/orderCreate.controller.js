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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OrderCreateController = void 0;
const prisma_1 = __importDefault(require("../../config/prisma"));
const services_1 = require("../../services");
const types_1 = require("../../models/types");
const shared_1 = require("./shared");
const notificationTemplates_1 = require("../../utils/notificationTemplates");
class OrderCreateController {
    static createOrder(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b, _c;
            console.log('[OrderController] Starting order creation');
            try {
                const { serviceId, addressId, isRecurring, recurrenceType, collectionDate, deliveryDate, affiliateCode, items, paymentMethod, appliedOfferIds, serviceTypeId, userId: userIdFromPayload, // Correction ici
                note } = req.body;
                // Logique hybride :
                // - Si admin/superadmin ET userId fourni dans le payload, on l'utilise
                // - Sinon, on utilise l'utilisateur authentifié
                const isAdmin = ((_a = req.user) === null || _a === void 0 ? void 0 : _a.role) === 'ADMIN' || ((_b = req.user) === null || _b === void 0 ? void 0 : _b.role) === 'SUPER_ADMIN';
                const userId = isAdmin && userIdFromPayload ? userIdFromPayload : (_c = req.user) === null || _c === void 0 ? void 0 : _c.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                // 1. Calculer le prix total avec les réductions
                // 1. Récupérer les offres actives auxquelles l'utilisateur est inscrit
                const userOffers = yield prisma_1.default.offer_subscriptions.findMany({
                    where: {
                        userId,
                        status: 'ACTIVE',
                        offers: {
                            is_active: true,
                            startDate: { lte: new Date() },
                            endDate: { gte: new Date() }
                        }
                    },
                    include: {
                        offers: {
                            include: {
                                offer_articles: true
                            }
                        }
                    }
                });
                // 2. Filtrer les offres valides de façon flexible
                const validOffers = userOffers
                    .map(sub => sub.offers)
                    .filter((offer) => !!offer);
                const filteredValidOffers = validOffers.filter(offer => {
                    if (!offer)
                        return false;
                    // Articles concernés : si la condition existe, on la vérifie, sinon on passe
                    if (Array.isArray(offer.offer_articles) && offer.offer_articles.length > 0) {
                        const offerArticleIds = offer.offer_articles.map(a => a.article_id);
                        const hasValidArticle = items.some((item) => offerArticleIds.includes(item.articleId));
                        if (!hasValidArticle)
                            return false;
                    }
                    // Montant minimum d'achat : si défini et > 0, on vérifie, sinon on passe
                    if (typeof offer.minPurchaseAmount === 'number' && offer.minPurchaseAmount > 0) {
                        const subtotal = items.reduce((sum, item) => sum + (item.unitPrice || 0) * item.quantity, 0);
                        if (subtotal < offer.minPurchaseAmount)
                            return false;
                    }
                    // Dates de validité : si définies, on vérifie, sinon on passe
                    if (offer.startDate && new Date() < new Date(offer.startDate))
                        return false;
                    if (offer.endDate && new Date() > new Date(offer.endDate))
                        return false;
                    return true;
                });
                // 3. Séparer cumulables et non-cumulables
                const cumulableOffers = filteredValidOffers.filter(o => o && o.isCumulative === true);
                const nonCumulableOffers = filteredValidOffers.filter(o => o && o.isCumulative === false);
                // 4. Appliquer la meilleure offre non-cumulable (si présente), sinon toutes les cumulables
                let appliedOffers = [];
                if (nonCumulableOffers.length) {
                    // Prendre la plus avantageuse
                    const bestOffer = nonCumulableOffers.reduce((max, offer) => {
                        if (!offer || !max)
                            return max || offer;
                        return (Number(offer.discountValue) > Number(max.discountValue)) ? offer : max;
                    }, nonCumulableOffers[0]);
                    appliedOffers = bestOffer ? [bestOffer] : [];
                }
                else {
                    appliedOffers = cumulableOffers;
                }
                // 5. Calculer le prix total avec les réductions
                const pricing = yield services_1.PricingService.calculateOrderTotal({
                    items,
                    userId,
                    appliedOfferIds: appliedOffers.filter((o) => !!o && typeof o.id === 'string').map(o => o.id)
                });
                // 2. Créer la commande avec le montant total
                const order = yield prisma_1.default.orders.create({
                    data: {
                        userId,
                        serviceId,
                        addressId,
                        isRecurring,
                        recurrenceType,
                        nextRecurrenceDate: null,
                        totalAmount: pricing.total,
                        collectionDate,
                        deliveryDate,
                        affiliateCode,
                        paymentMethod,
                        status: 'PENDING',
                        service_type_id: serviceTypeId,
                        createdAt: new Date(),
                        updatedAt: new Date()
                    }
                });
                // Création de la note unique (si fournie)
                let noteRecord = null;
                if (note && typeof note === 'string' && note.trim().length > 0) {
                    noteRecord = yield prisma_1.default.order_notes.create({
                        data: {
                            order_id: order.id,
                            note,
                            created_at: new Date(),
                            updated_at: new Date()
                        }
                    });
                }
                // 3. Récupérer les prix réels des couples article/service/serviceType/service
                // IMPORTANT : Le couple prix DOIT matcher sur le trio (article_id, service_type_id, service_id) !
                // Si on ne filtre pas sur les trois, on peut récupérer un prix d'un autre service ou d'un autre couple, ce qui fausse le calcul.
                // Cette subtilité est source de bugs fréquents : TOUJOURS filtrer sur les trois clés pour garantir le bon prix.
                const couplePrices = yield prisma_1.default.article_service_prices.findMany({
                    where: {
                        article_id: { in: items.map((item) => item.articleId) },
                        service_type_id: serviceTypeId,
                        service_id: serviceId
                    }
                });
                // On log les couples trouvés pour debug (à retirer en prod)
                console.log('[OrderController] Couples prix utilisés (ids):', couplePrices.map(c => c.id));
                const couplePriceMap = new Map(couplePrices
                    .filter(c => c.article_id)
                    .map(c => [c.article_id, { base_price: Number(c.base_price), premium_price: Number(c.premium_price) }]));
                // 4. Créer les items de commande avec le bon prix
                const mappedItems = items.map((item) => {
                    var _a;
                    const couple = couplePriceMap.get(item.articleId);
                    const unitPrice = couple
                        ? (item.isPremium ? couple.premium_price : couple.base_price)
                        : 1; // fallback si pas trouvé
                    return {
                        orderId: order.id,
                        articleId: item.articleId,
                        serviceId,
                        quantity: item.quantity,
                        unitPrice,
                        createdAt: new Date(),
                        updatedAt: new Date(),
                        isPremium: (_a = item.isPremium) !== null && _a !== void 0 ? _a : false
                    };
                });
                console.log('[OrderController] Payload order_items (mapped with couple prices):', mappedItems);
                yield prisma_1.default.order_items.createMany({
                    data: mappedItems
                });
                // 5. Si code affilié, créer transaction de commission
                if (affiliateCode) {
                    const affiliate = yield prisma_1.default.affiliate_profiles.findUnique({
                        where: { affiliate_code: affiliateCode }
                    });
                    if (affiliate) {
                        yield prisma_1.default.commission_transactions.create({
                            data: {
                                affiliate_id: affiliate.id,
                                order_id: order.id,
                                amount: pricing.total * Number(affiliate.commission_rate || 0) / 100,
                                status: 'PENDING'
                            }
                        });
                    }
                }
                // 6. Récupérer la commande complète avec relations
                const orderData = yield prisma_1.default.orders.findUnique({
                    where: { id: order.id },
                    include: {
                        user: true,
                        address: true,
                        order_items: {
                            include: {
                                article: true
                            }
                        }
                    }
                });
                const noteUnique = (noteRecord === null || noteRecord === void 0 ? void 0 : noteRecord.note) || null;
                if (!orderData) {
                    throw new Error('Failed to retrieve complete order');
                }
                const formattedOrder = {
                    id: orderData.id,
                    userId: orderData.userId,
                    service_id: orderData.serviceId || '',
                    address_id: orderData.addressId || '',
                    affiliateCode: orderData.affiliateCode || undefined,
                    status: orderData.status || 'PENDING',
                    isRecurring: orderData.isRecurring || false,
                    recurrenceType: orderData.recurrenceType || null,
                    nextRecurrenceDate: orderData.nextRecurrenceDate || undefined,
                    totalAmount: Number(orderData.totalAmount || 0),
                    collectionDate: orderData.collectionDate || undefined,
                    deliveryDate: orderData.deliveryDate || undefined,
                    createdAt: orderData.createdAt || new Date(),
                    updatedAt: orderData.updatedAt || new Date(),
                    service_type_id: orderData.service_type_id,
                    paymentStatus: types_1.PaymentStatus.PENDING,
                    paymentMethod: orderData.paymentMethod || types_1.PaymentMethod.CASH,
                    items: orderData.order_items.map(item => {
                        var _a;
                        return ({
                            id: item.id,
                            orderId: item.orderId,
                            articleId: item.articleId,
                            serviceId: item.serviceId,
                            quantity: item.quantity,
                            unitPrice: Number(item.unitPrice),
                            isPremium: (_a = item.isPremium) !== null && _a !== void 0 ? _a : undefined,
                            createdAt: item.createdAt,
                            updatedAt: item.updatedAt,
                            article: item.article ? {
                                id: item.article.id,
                                categoryId: item.article.categoryId || '',
                                name: item.article.name,
                                description: item.article.description || '',
                                basePrice: Number(item.article.basePrice),
                                premiumPrice: Number(item.article.premiumPrice || 0),
                                createdAt: item.article.createdAt || new Date(),
                                updatedAt: item.article.updatedAt || new Date()
                            } : undefined
                        });
                    }),
                    note: noteUnique
                };
                // 7. Traiter les points et notifications
                const earnedPoints = Math.floor(pricing.total * services_1.SYSTEM_CONSTANTS.POINTS.ORDER_MULTIPLIER);
                yield services_1.RewardsService.processOrderPoints(userId, formattedOrder, 'ORDER');
                const user = {
                    id: orderData.user.id,
                    email: orderData.user.email,
                    firstName: orderData.user.first_name,
                    lastName: orderData.user.last_name,
                    phone: orderData.user.phone || undefined,
                    role: orderData.user.role || 'CLIENT',
                    password: '',
                    createdAt: orderData.user.created_at || new Date(),
                    updatedAt: orderData.user.updated_at || new Date()
                };
                const notificationTemplate = notificationTemplates_1.orderNotificationTemplates.orderCreated(formattedOrder, user);
                yield services_1.NotificationService.createNotification(userId, types_1.NotificationType.ORDER_CREATED, notificationTemplate.message, notificationTemplate.data);
                // 8. Préparer et envoyer la réponse
                const response = {
                    order: formattedOrder,
                    pricing,
                    rewards: {
                        pointsEarned: earnedPoints,
                        currentBalance: yield shared_1.OrderSharedMethods.getUserPoints(userId)
                    }
                };
                res.status(201).json({ data: response });
            }
            catch (error) {
                console.error('[OrderController] Error creating order:', error);
                res.status(500).json({
                    error: error.message || 'Error creating order',
                    details: process.env.NODE_ENV === 'development' ? error : undefined
                });
            }
        });
    }
    static calculateTotal(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { items, appliedOfferIds } = req.body;
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const pricing = yield services_1.PricingService.calculateOrderTotal({
                    items,
                    userId,
                    appliedOfferIds
                });
                res.json({ data: pricing });
            }
            catch (error) {
                console.error('[OrderController] Error calculating total:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
}
exports.OrderCreateController = OrderCreateController;
