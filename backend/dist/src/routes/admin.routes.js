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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const subscription_routes_1 = __importDefault(require("./subscription.routes"));
const affiliateLinkAdmin_routes_1 = __importDefault(require("./affiliateLinkAdmin.routes"));
const express_1 = __importDefault(require("express"));
const admin_controller_1 = require("../controllers/admin.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const asyncHandler_1 = require("../utils/asyncHandler");
const admin_service_1 = require("../services/admin.service");
const serviceManagement_controller_1 = require("../controllers/admin/serviceManagement.controller");
const orderQuery_controller_1 = require("../controllers/order.controller/orderQuery.controller");
const priceValidation_middleware_1 = require("../middleware/priceValidation.middleware");
const router = express_1.default.Router();
// Protection des routes avec authentification
router.use(auth_middleware_1.authenticateToken);
// Register subscription management routes under /admin/subscriptions
router.use('/subscriptions', subscription_routes_1.default);
// Routes de gestion des affiliés
router.get('/affiliates', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { AffiliateController } = yield Promise.resolve().then(() => __importStar(require('../controllers/affiliate.controller')));
    yield AffiliateController.getAllAffiliates(req, res);
})));
router.get('/affiliates/stats', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { AffiliateController } = yield Promise.resolve().then(() => __importStar(require('../controllers/affiliate.controller')));
    yield AffiliateController.getAffiliateStats(req, res);
})));
router.get('/affiliates/withdrawals/pending', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { AffiliateController } = yield Promise.resolve().then(() => __importStar(require('../controllers/affiliate.controller')));
    yield AffiliateController.getPendingWithdrawals(req, res);
})));
router.get('/affiliates/withdrawals', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { AffiliateController } = yield Promise.resolve().then(() => __importStar(require('../controllers/affiliate.controller')));
    yield AffiliateController.getWithdrawals(req, res);
})));
router.patch('/affiliates/withdrawals/:withdrawalId/reject', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { AffiliateController } = yield Promise.resolve().then(() => __importStar(require('../controllers/affiliate.controller')));
    yield AffiliateController.rejectWithdrawal(req, res);
})));
router.patch('/affiliates/withdrawals/:withdrawalId/approve', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const { AffiliateController } = yield Promise.resolve().then(() => __importStar(require('../controllers/affiliate.controller')));
    yield AffiliateController.approveWithdrawal(req, res);
})));
// Routes de liaison affilié-client (CRUD)
router.use('/affiliate-links', affiliateLinkAdmin_routes_1.default);
// Routes de gestion des commandes
router.get('/orders', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 50;
        const status = req.query.status; // Correction ici
        const sortField = req.query.sort_field || 'createdAt';
        const sortOrder = req.query.sort_order || 'desc';
        const result = yield admin_service_1.AdminService.getAllOrders(page, limit, {
            status,
            sortField,
            sortOrder
        });
        res.json({
            success: true,
            data: result.orders,
            pagination: {
                total: result.total,
                currentPage: page,
                limit,
                totalPages: result.pages
            }
        });
    }
    catch (error) {
        console.error('Error handling orders request:', error);
        res.status(500).json({
            success: false,
            error: 'Internal Server Error',
            message: 'Failed to fetch orders'
        });
    }
})));
router.get('/orders/by-status', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(admin_controller_1.AdminController.getOrdersByStatus));
router.get('/orders/search', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield orderQuery_controller_1.OrderQueryController.searchOrders(req, res);
})));
// Route pour créer une commande au nom d'un client
router.post('/orders/create-for-customer', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield admin_controller_1.AdminController.createOrderForCustomer(req, res);
})));
// Routes statistiques et dashboard
router.get('/statistics', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const stats = yield admin_service_1.AdminService.getStatistics();
    // S'assurer que les données sont dans le bon format
    res.json({
        success: true,
        data: {
            totalRevenue: Number(stats.totalRevenue || 0),
            totalOrders: Number(stats.totalOrders || 0),
            totalCustomers: Number(stats.totalCustomers || 0),
            recentOrders: stats.recentOrders || [],
            ordersByStatus: stats.ordersByStatus || {}
        }
    });
})));
router.get('/revenue-chart', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const data = yield admin_service_1.AdminService.getRevenueChartData();
    // Utiliser la structure correcte du type RevenueChartData
    res.json({
        success: true,
        data: {
            labels: data.labels,
            data: data.data
        }
    });
})));
router.get('/revenue', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const stats = yield admin_service_1.AdminService.getStatistics();
    res.json({
        success: true,
        data: stats.totalRevenue
    });
})));
router.get('/customers', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const stats = yield admin_service_1.AdminService.getStatistics();
    res.json({
        success: true,
        data: stats.totalCustomers
    });
})));
// Routes super admin
router.post('/configure-commissions', (0, auth_middleware_1.authorizeRoles)(['SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield admin_controller_1.AdminController.configureCommissions(req, res);
})));
router.post('/configure-rewards', (0, auth_middleware_1.authorizeRoles)(['SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield admin_controller_1.AdminController.configureRewards(req, res);
})));
// Routes gestion des services et articles
router.post('/create-service', (0, auth_middleware_1.authorizeRoles)(['ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield admin_controller_1.AdminController.createService(req, res);
})));
router.post('/create-article', (0, auth_middleware_1.authorizeRoles)(['ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield admin_controller_1.AdminController.createArticle(req, res);
})));
router.get('/services', (0, auth_middleware_1.authorizeRoles)(['ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield admin_controller_1.AdminController.getAllServices(req, res);
})));
router.get('/articles', (0, auth_middleware_1.authorizeRoles)(['ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield admin_controller_1.AdminController.getAllArticles(req, res);
})));
router.patch('/services/:serviceId', (0, auth_middleware_1.authorizeRoles)(['ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield admin_controller_1.AdminController.updateService(req, res);
})));
router.patch('/articles/:articleId', (0, auth_middleware_1.authorizeRoles)(['ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield admin_controller_1.AdminController.updateArticle(req, res);
})));
router.patch('/affiliates/:affiliateId/status', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield admin_controller_1.AdminController.updateAffiliateStatus(req, res);
})));
router.delete('/services/:serviceId', (0, auth_middleware_1.authorizeRoles)(['ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield admin_controller_1.AdminController.deleteService(req, res);
})));
router.delete('/articles/:articleId', (0, auth_middleware_1.authorizeRoles)(['ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield admin_controller_1.AdminController.deleteArticle(req, res);
})));
// Routes de gestion des services
router.get('/services/configuration', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(serviceManagement_controller_1.ServiceManagementController.getServiceConfiguration));
router.put('/articles/:articleId/services', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), priceValidation_middleware_1.validatePriceData, (0, asyncHandler_1.asyncHandler)(serviceManagement_controller_1.ServiceManagementController.updateArticleServices));
// Routes de gestion du profil admin
router.get('/profile', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(admin_controller_1.AdminController.getProfile));
router.put('/profile', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(admin_controller_1.AdminController.updateProfile));
router.post('/profile/password', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(admin_controller_1.AdminController.updatePassword));
exports.default = router;
