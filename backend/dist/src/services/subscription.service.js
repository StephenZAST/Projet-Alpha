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
exports.SubscriptionService = void 0;
const client_1 = require("@prisma/client");
const types_1 = require("../models/types");
const notification_service_1 = require("./notification.service");
const prisma = new client_1.PrismaClient();
class SubscriptionService {
    static getAllPlans() {
        return __awaiter(this, void 0, void 0, function* () {
            // Récupère tous les plans d'abonnement
            const plans = yield prisma.subscription_plans.findMany();
            return plans.map(plan => {
                var _a;
                return ({
                    id: plan.id,
                    name: plan.name,
                    description: (_a = plan.description) !== null && _a !== void 0 ? _a : undefined,
                    price: Number(plan.price),
                    duration_days: plan.duration_days,
                    max_orders_per_month: plan.max_orders_per_month,
                    max_weight_per_order: plan.max_weight_per_order ? Number(plan.max_weight_per_order) : undefined,
                    is_premium: plan.is_premium,
                    created_at: plan.created_at,
                    updated_at: plan.updated_at
                });
            });
        });
    }
    // Vérifie et met à jour l’expiration des abonnements (à appeler périodiquement ou lors de chaque accès)
    static expireSubscriptions() {
        return __awaiter(this, void 0, void 0, function* () {
            const now = new Date();
            // Table user_subscriptions n'existe pas, on retire cette logique ou l'adapte si besoin
            // TODO: Adapter la logique d'expiration si une table d'abonnement utilisateur existe
        });
    }
    // Helper pour récupérer le prix d’un article/service via la logique centralisée
    static getCentralizedServicePrice(articleId, serviceTypeId, weight) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // Appel direct à la fonction stockée pour obtenir le prix
                const result = yield prisma.$queryRaw `SELECT public.calculate_service_price(${articleId}, ${serviceTypeId}, ${weight !== null && weight !== void 0 ? weight : null}) AS price`;
                if (Array.isArray(result) && result.length > 0 && result[0].price !== null) {
                    return Number(result[0].price);
                }
                return null;
            }
            catch (error) {
                console.error('[SubscriptionService] Centralized price error:', error);
                throw error;
            }
        });
    }
    static createPlan(planData) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b, _c, _d, _e;
            try {
                const data = yield prisma.subscription_plans.create({
                    data: {
                        id: planData.id,
                        name: planData.name,
                        description: (_a = planData.description) !== null && _a !== void 0 ? _a : undefined,
                        price: planData.price,
                        duration_days: (_b = planData.duration_days) !== null && _b !== void 0 ? _b : 30,
                        max_orders_per_month: (_c = planData.max_orders_per_month) !== null && _c !== void 0 ? _c : 10,
                        max_weight_per_order: planData.max_weight_per_order,
                        is_premium: (_d = planData.is_premium) !== null && _d !== void 0 ? _d : false,
                    }
                });
                return {
                    id: data.id,
                    name: data.name,
                    description: (_e = data.description) !== null && _e !== void 0 ? _e : undefined,
                    price: Number(data.price),
                    duration_days: data.duration_days,
                    max_orders_per_month: data.max_orders_per_month,
                    max_weight_per_order: data.max_weight_per_order ? Number(data.max_weight_per_order) : undefined,
                    is_premium: data.is_premium,
                    created_at: data.created_at,
                    updated_at: data.updated_at
                };
            }
            catch (error) {
                console.error('[SubscriptionService] Error creating plan:', error);
                throw error;
            }
        });
    }
    static subscribeToPlan(userId, planId) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const now = new Date();
                const plan = yield prisma.subscription_plans.findUnique({ where: { id: planId } });
                if (!plan)
                    throw new Error('Plan not found');
                const endDate = new Date(now.getTime() + plan.duration_days * 24 * 60 * 60 * 1000);
                const userSub = yield prisma.user_subscriptions.create({
                    data: {
                        userId: userId,
                        plan_id: planId,
                        start_date: now,
                        end_date: endDate,
                        status: 'ACTIVE',
                        remaining_orders: plan.max_orders_per_month,
                        expired: false,
                    }
                });
                return {
                    id: userSub.id,
                    userId: userSub.userId,
                    planId: userSub.plan_id,
                    startDate: userSub.start_date,
                    endDate: userSub.end_date,
                    status: userSub.status,
                    remainingWeight: plan.max_weight_per_order ? Number(plan.max_weight_per_order) : 0,
                    remainingOrders: (_a = userSub.remaining_orders) !== null && _a !== void 0 ? _a : 0,
                    expired: userSub.expired,
                    createdAt: userSub.created_at,
                    updatedAt: userSub.updated_at
                };
            }
            catch (error) {
                console.error('[SubscriptionService] Error subscribing to plan:', error);
                throw error;
            }
        });
    }
    static getUserActiveSubscription(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            // Met à jour l’expiration avant de chercher l’abonnement actif
            yield SubscriptionService.expireSubscriptions();
            try {
                const subscription = yield prisma.user_subscriptions.findFirst({
                    where: {
                        userId: userId,
                        status: 'ACTIVE',
                        end_date: { gte: new Date() },
                        expired: false,
                    },
                    orderBy: { start_date: 'desc' }
                });
                if (!subscription)
                    return null;
                const plan = yield prisma.subscription_plans.findUnique({ where: { id: subscription.plan_id } });
                return {
                    id: subscription.id,
                    userId: subscription.userId,
                    planId: subscription.plan_id,
                    startDate: subscription.start_date,
                    endDate: subscription.end_date,
                    status: subscription.status,
                    remainingWeight: (plan === null || plan === void 0 ? void 0 : plan.max_weight_per_order) ? Number(plan.max_weight_per_order) : 0,
                    remainingOrders: (_a = subscription.remaining_orders) !== null && _a !== void 0 ? _a : 0,
                    expired: subscription.expired,
                    createdAt: subscription.created_at,
                    updatedAt: subscription.updated_at
                };
            }
            catch (error) {
                console.error('[SubscriptionService] Error getting active subscription:', error);
                throw error;
            }
        });
    }
    static cancelSubscription(userId, subscriptionId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.user_subscriptions.update({
                    where: { id: subscriptionId },
                    data: { status: 'CANCELLED', expired: true, updated_at: new Date() }
                });
                yield notification_service_1.NotificationService.sendNotification(userId, types_1.NotificationType.SUBSCRIPTION_CANCELLED, {
                    title: 'Abonnement annulé',
                    message: 'Votre abonnement a été annulé avec succès'
                });
            }
            catch (error) {
                console.error('[SubscriptionService] Error cancelling subscription:', error);
                throw error;
            }
        });
    }
    static checkSubscriptionUsage(subscriptionId, weightKg) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const subscription = yield prisma.user_subscriptions.findUnique({ where: { id: subscriptionId } });
                if (!subscription)
                    throw new Error('Subscription not found');
                if (subscription.expired || subscription.status !== 'ACTIVE')
                    return false;
                if (typeof subscription.remaining_orders === 'number' && subscription.remaining_orders <= 0)
                    return false;
                if (subscription.end_date < new Date())
                    return false;
                if (weightKg !== undefined) {
                    const plan = yield prisma.subscription_plans.findUnique({ where: { id: subscription.plan_id } });
                    if ((plan === null || plan === void 0 ? void 0 : plan.max_weight_per_order) !== undefined && weightKg > Number(plan.max_weight_per_order))
                        return false;
                }
                return true;
            }
            catch (error) {
                console.error('[SubscriptionService] Error checking subscription usage:', error);
                throw error;
            }
        });
    }
    static getPlanSubscribersWithNames(planId) {
        return __awaiter(this, void 0, void 0, function* () {
            // Récupère tous les abonnements pour un plan donné, avec le nom de l'utilisateur
            const subs = yield prisma.user_subscriptions.findMany({
                where: { plan_id: planId },
                include: { users: true }, // Correction : la relation s'appelle 'users' dans Prisma
            });
            return subs.map(sub => {
                var _a, _b, _c, _d;
                return ({
                    id: sub.id,
                    userId: sub.userId,
                    userName: ((_a = sub.users) === null || _a === void 0 ? void 0 : _a.first_name) ? `${sub.users.first_name} ${(_b = sub.users.last_name) !== null && _b !== void 0 ? _b : ''}`.trim() : (_d = (_c = sub.users) === null || _c === void 0 ? void 0 : _c.email) !== null && _d !== void 0 ? _d : '',
                    planId: sub.plan_id,
                    startDate: sub.start_date,
                    endDate: sub.end_date,
                    status: sub.status,
                    remainingOrders: sub.remaining_orders,
                    expired: sub.expired,
                    createdAt: sub.created_at,
                    updatedAt: sub.updated_at
                });
            });
        });
    }
}
exports.SubscriptionService = SubscriptionService;
