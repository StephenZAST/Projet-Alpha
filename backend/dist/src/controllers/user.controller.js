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
exports.UserController = void 0;
const auth_service_1 = require("../services/auth.service");
const client_1 = require("@prisma/client");
const offer_service_1 = require("../services/offer.service");
const subscription_service_1 = require("../services/subscription.service");
const prisma = new client_1.PrismaClient();
class UserController {
    /**
     * Endpoint pour récupérer les détails d'un utilisateur, avec ses offres actives et abonnements
     * GET /api/users/:userId/details
     */
    static getUserDetails(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const userId = req.params.userId;
                const user = yield prisma.users.findUnique({ where: { id: userId } });
                if (!user)
                    return res.status(404).json({ error: 'Utilisateur non trouvé' });
                // Offres actives (abonnements)
                const activeOfferSubscriptions = yield offer_service_1.OfferService.getUserSubscriptions(userId);
                // Offres liées (historique)
                const userOffers = yield prisma.user_offers.findMany({
                    where: { userId },
                    include: { offers: true }
                });
                // Abonnement utilisateur (plan)
                const activeSubscription = yield subscription_service_1.SubscriptionService.getUserActiveSubscription(userId);
                return res.json({
                    success: true,
                    data: {
                        user,
                        activeOfferSubscriptions,
                        userOffers,
                        activeSubscription
                    }
                });
            }
            catch (error) {
                console.error('[UserController] getUserDetails error:', error);
                return res.status(500).json({
                    success: false,
                    error: error.message || 'Erreur lors de la récupération des détails utilisateur',
                    details: error.stack || error
                });
            }
        });
    }
    /**
     * Endpoint de recherche paginée et filtrée d'utilisateurs (tous rôles, recherche, etc.)
     * GET /api/users/search?role=CLIENT&page=1&limit=10&query=...&filter=name
     */
    static searchUsers(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { query = '', filter = 'all', role = 'all', page = 1, limit = 10, } = req.query;
                // Appel du service centralisé
                const result = yield auth_service_1.AuthService.searchUsers({
                    role: String(role),
                    query: String(query),
                    filter: String(filter),
                    page: Number(page),
                    limit: Number(limit)
                });
                // Enrichissement des données utilisateur pour chaque résultat
                const enrichedData = yield Promise.all(result.data.map((user) => __awaiter(this, void 0, void 0, function* () {
                    // Offres actives (abonnements)
                    const activeOfferSubscriptions = yield offer_service_1.OfferService.getUserSubscriptions(user.id);
                    // Offres liées (historique)
                    const userOffers = yield prisma.user_offers.findMany({
                        where: { userId: user.id },
                        include: { offers: true }
                    });
                    // Abonnement utilisateur (plan)
                    const activeSubscription = yield subscription_service_1.SubscriptionService.getUserActiveSubscription(user.id);
                    return Object.assign(Object.assign({}, user), { activeOfferSubscriptions,
                        userOffers,
                        activeSubscription });
                })));
                return res.json({
                    success: true,
                    data: enrichedData,
                    pagination: result.pagination
                });
            }
            catch (error) {
                console.error('[UserController] Search error:', error);
                return res.status(500).json({
                    success: false,
                    error: error.message || 'Erreur lors de la recherche des utilisateurs',
                    details: error.stack || error
                });
            }
        });
    }
}
exports.UserController = UserController;
