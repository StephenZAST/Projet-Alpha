"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
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
exports.OrderCreateService = void 0;
const client_1 = require("@prisma/client");
const types_1 = require("../../models/types");
const notification_service_1 = require("../notification.service");
const loyalty_service_1 = require("../loyalty.service");
const orderPayment_service_1 = require("./orderPayment.service");
const prisma = new client_1.PrismaClient();
class OrderCreateService {
    static createOrder(orderData) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            // Vérification d’abonnement actif
            const subscription = yield Promise.resolve().then(() => __importStar(require('../subscription.service'))).then(m => m.SubscriptionService.getUserActiveSubscription(orderData.userId));
            const isSubscriptionOrder = !!subscription;
            // --- Injection automatique du code affilié si non fourni ---
            let affiliateCodeToUse = orderData.affiliateCode;
            if (!affiliateCodeToUse) {
                // Chercher une liaison active pour ce client
                const now = new Date();
                const link = yield prisma.affiliate_client_links.findFirst({
                    where: {
                        client_id: orderData.userId,
                        start_date: { lte: now },
                        OR: [
                            { end_date: null },
                            { end_date: { gte: now } }
                        ],
                        affiliate: {
                            is_active: true,
                            status: 'ACTIVE'
                        }
                    },
                    include: {
                        affiliate: true
                    },
                    orderBy: { start_date: 'desc' }
                });
                if (link && link.affiliate && link.affiliate.affiliate_code) {
                    affiliateCodeToUse = link.affiliate.affiliate_code;
                }
            }
            try {
                const service_type_id = orderData.service_type_id || orderData.serviceTypeId;
                if (!service_type_id) {
                    throw new Error('service_type_id is required');
                }
                // Vérification des articles
                const articles = yield prisma.articles.findMany({
                    where: {
                        id: { in: orderData.items.map(item => item.articleId) },
                        isDeleted: false
                    }
                });
                if (articles.length !== orderData.items.length) {
                    throw new Error('One or more articles are not available');
                }
                // Calculer le prix de chaque item via PricingService
                const PricingService = require('../pricing.service').PricingService;
                const orderItemsWithPrice = [];
                for (const item of orderData.items) {
                    const priceDetails = yield PricingService.calculatePrice({
                        articleId: item.articleId,
                        serviceTypeId: service_type_id,
                        quantity: item.quantity,
                        isPremium: item.premiumPrice || false,
                        weight: item.weight
                    });
                    orderItemsWithPrice.push({
                        articleId: item.articleId,
                        serviceId: orderData.serviceId,
                        quantity: item.quantity,
                        isPremium: item.premiumPrice || false,
                        unitPrice: priceDetails.basePrice,
                        weight: item.weight
                    });
                }
                // Création de la commande avec les bons prix
                const createdOrder = yield prisma.orders.create({
                    data: {
                        userId: orderData.userId,
                        serviceId: orderData.serviceId,
                        addressId: orderData.addressId,
                        status: 'PENDING',
                        isRecurring: orderData.isRecurring || false,
                        recurrenceType: orderData.recurrenceType,
                        collectionDate: orderData.collectionDate,
                        deliveryDate: orderData.deliveryDate,
                        affiliateCode: affiliateCodeToUse,
                        service_type_id: service_type_id,
                        paymentMethod: orderData.paymentMethod,
                        order_items: {
                            create: orderItemsWithPrice
                        }
                    },
                    include: {
                        order_items: {
                            include: {
                                article: {
                                    include: {
                                        article_categories: true
                                    }
                                }
                            }
                        },
                        service_types: true
                    }
                });
                // Calcul du montant total
                const totalAmount = yield orderPayment_service_1.OrderPaymentService.calculateTotal(orderData.items);
                let finalAmount = totalAmount;
                let appliedDiscounts = [];
                if ((_a = orderData.offerIds) === null || _a === void 0 ? void 0 : _a.length) {
                    const discountResult = yield orderPayment_service_1.OrderPaymentService.calculateDiscounts(orderData.userId, finalAmount, orderData.items.map(item => item.articleId), orderData.offerIds);
                    finalAmount = discountResult.finalAmount;
                    appliedDiscounts = discountResult.appliedDiscounts;
                }
                // Toujours mettre à jour le totalAmount de la commande avec le vrai total calculé
                yield prisma.orders.update({
                    where: { id: createdOrder.id },
                    data: { totalAmount: finalAmount }
                });
                // Rafraîchir la commande pour avoir le totalAmount à jour
                const refreshedOrder = yield prisma.orders.findUnique({
                    where: { id: createdOrder.id },
                    include: {
                        order_items: {
                            include: {
                                article: {
                                    include: {
                                        article_categories: true
                                    }
                                }
                            }
                        },
                        service_types: true
                    }
                });
                // Traitement affilié et points
                if (affiliateCodeToUse) {
                    yield orderPayment_service_1.OrderPaymentService.processAffiliateCommission(createdOrder.id, affiliateCodeToUse, finalAmount);
                    // Créer automatiquement une liaison affilié-client si elle n'existe pas
                    yield this.ensureAffiliateClientLink(orderData.userId, affiliateCodeToUse);
                }
                const earnedPoints = Math.floor(finalAmount);
                yield loyalty_service_1.LoyaltyService.earnPoints(orderData.userId, earnedPoints, 'ORDER', createdOrder.id);
                // Notification
                const orderItems = yield prisma.order_items.findMany({
                    where: { orderId: createdOrder.id },
                    include: { article: true }
                });
                yield notification_service_1.NotificationService.createOrderNotification(orderData.userId, createdOrder.id, types_1.NotificationType.ORDER_CREATED, {
                    totalAmount: finalAmount,
                    items: orderItems.map(item => {
                        var _a;
                        return ({
                            name: ((_a = item.article) === null || _a === void 0 ? void 0 : _a.name) || 'Unknown Article',
                            quantity: item.quantity
                        });
                    })
                });
                // Construction de la réponse avec la commande rafraîchie
                if (!refreshedOrder) {
                    throw new Error('Order not found after update');
                }
                const orderResponse = {
                    id: refreshedOrder.id,
                    userId: refreshedOrder.userId,
                    service_id: refreshedOrder.serviceId || '',
                    address_id: refreshedOrder.addressId || '',
                    status: refreshedOrder.status || 'PENDING',
                    isRecurring: refreshedOrder.isRecurring || false,
                    recurrenceType: refreshedOrder.recurrenceType || 'NONE',
                    totalAmount: Number(refreshedOrder.totalAmount),
                    createdAt: refreshedOrder.createdAt || new Date(),
                    updatedAt: refreshedOrder.updatedAt || new Date(),
                    service_type_id: service_type_id,
                    paymentStatus: types_1.PaymentStatus.PENDING,
                    paymentMethod: orderData.paymentMethod,
                    affiliateCode: refreshedOrder.affiliateCode || undefined,
                    items: refreshedOrder.order_items.map(item => {
                        var _a, _b;
                        return ({
                            id: item.id,
                            orderId: item.orderId,
                            articleId: item.articleId,
                            serviceId: item.serviceId,
                            quantity: item.quantity,
                            unitPrice: Number(item.unitPrice),
                            isPremium: item.isPremium || false,
                            createdAt: item.createdAt,
                            updatedAt: item.updatedAt,
                            article: item.article
                                ? Object.assign(Object.assign({}, item.article), { categoryId: (_a = item.article.categoryId) !== null && _a !== void 0 ? _a : '', description: (_b = item.article.description) !== null && _b !== void 0 ? _b : '', basePrice: item.article.basePrice ? Number(item.article.basePrice) : 0, premiumPrice: item.article.premiumPrice ? Number(item.article.premiumPrice) : 0, createdAt: item.article.createdAt ? new Date(item.article.createdAt) : new Date(), updatedAt: item.article.updatedAt ? new Date(item.article.updatedAt) : new Date() }) : undefined
                        });
                    })
                };
                const currentPoints = yield orderPayment_service_1.OrderPaymentService.getCurrentLoyaltyPoints(orderData.userId);
                return {
                    order: orderResponse,
                    pricing: {
                        subtotal: finalAmount, // synchronisé avec le vrai total
                        discounts: appliedDiscounts,
                        total: finalAmount
                    },
                    rewards: {
                        pointsEarned: earnedPoints,
                        currentBalance: currentPoints
                    },
                    isSubscriptionOrder
                };
            }
            catch (error) {
                console.error('[OrderService] Error creating order:', error);
                throw error;
            }
        });
    }
    /**
     * Assure qu'une liaison affilié-client existe pour ce client et ce code affilié
     */
    static ensureAffiliateClientLink(clientId, affiliateCode) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // Trouver l'affilié par son code
                const affiliate = yield prisma.affiliate_profiles.findUnique({
                    where: { affiliate_code: affiliateCode }
                });
                if (!affiliate) {
                    console.warn('[OrderCreateService] Affiliate not found for code:', affiliateCode);
                    return;
                }
                // Vérifier si une liaison existe déjà
                const existingLink = yield prisma.affiliate_client_links.findFirst({
                    where: {
                        affiliate_id: affiliate.id,
                        client_id: clientId
                    }
                });
                if (existingLink) {
                    console.log('[OrderCreateService] Affiliate-client link already exists');
                    return;
                }
                // Créer la liaison automatiquement
                yield prisma.affiliate_client_links.create({
                    data: {
                        affiliate_id: affiliate.id,
                        client_id: clientId,
                        start_date: new Date(),
                        end_date: null, // Liaison permanente
                        created_by: null // Création automatique
                    }
                });
                console.log('[OrderCreateService] ✅ Auto-created affiliate-client link:', {
                    affiliateId: affiliate.id,
                    clientId: clientId,
                    affiliateCode: affiliateCode
                });
            }
            catch (error) {
                console.error('[OrderCreateService] Error ensuring affiliate-client link:', error);
                // Ne pas faire échouer la commande pour cette erreur
            }
        });
    }
}
exports.OrderCreateService = OrderCreateService;
