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
exports.SubscriptionController = void 0;
const subscription_service_1 = require("../services/subscription.service");
class SubscriptionController {
    static getAllPlans(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const plans = yield subscription_service_1.SubscriptionService.getAllPlans();
                res.json({ success: true, data: plans });
            }
            catch (error) {
                res.status(400).json({ success: false, error: (_a = error.message) !== null && _a !== void 0 ? _a : 'Erreur lors de la récupération des plans.' });
            }
        });
    }
    static createPlan(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const plan = yield subscription_service_1.SubscriptionService.createPlan(req.body);
                res.status(201).json({
                    success: true,
                    data: plan
                });
            }
            catch (error) {
                res.status(400).json({
                    success: false,
                    error: (_a = error.message) !== null && _a !== void 0 ? _a : 'Erreur lors de la création du plan.'
                });
            }
        });
    }
    static subscribeToPlan(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            try {
                const { planId } = req.body;
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    throw new Error('User not authenticated');
                const subscription = yield subscription_service_1.SubscriptionService.subscribeToPlan(userId, planId);
                res.json({
                    success: true,
                    data: subscription
                });
            }
            catch (error) {
                res.status(400).json({
                    success: false,
                    error: (_b = error.message) !== null && _b !== void 0 ? _b : 'Erreur lors de la souscription au plan.'
                });
            }
        });
    }
    static getActiveSubscription(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    throw new Error('User not authenticated');
                const subscription = yield subscription_service_1.SubscriptionService.getUserActiveSubscription(userId);
                res.json({
                    success: true,
                    data: subscription
                });
            }
            catch (error) {
                res.status(400).json({
                    success: false,
                    error: (_b = error.message) !== null && _b !== void 0 ? _b : 'Erreur lors de la récupération de l’abonnement.'
                });
            }
        });
    }
    static cancelSubscription(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                const { subscriptionId } = req.params;
                if (!userId)
                    throw new Error('User not authenticated');
                yield subscription_service_1.SubscriptionService.cancelSubscription(userId, subscriptionId);
                res.json({
                    success: true,
                    message: 'Subscription cancelled successfully'
                });
            }
            catch (error) {
                res.status(400).json({
                    success: false,
                    error: (_b = error.message) !== null && _b !== void 0 ? _b : 'Erreur lors de l’annulation de l’abonnement.'
                });
            }
        });
    }
    static getPlanSubscribersWithNames(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { planId } = req.params;
                const subscribers = yield subscription_service_1.SubscriptionService.getPlanSubscribersWithNames(planId);
                res.json({ success: true, data: subscribers });
            }
            catch (error) {
                res.status(400).json({ success: false, error: (_a = error.message) !== null && _a !== void 0 ? _a : 'Erreur lors de la récupération des abonnés.' });
            }
        });
    }
}
exports.SubscriptionController = SubscriptionController;
