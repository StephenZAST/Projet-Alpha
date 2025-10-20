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
exports.AdminController = void 0;
const admin_service_1 = require("../services/admin.service");
const prisma_1 = __importDefault(require("../config/prisma"));
class AdminController {
    // Profile management methods
    static getProfile(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId) {
                    return res.status(401).json({
                        success: false,
                        error: 'Unauthorized'
                    });
                }
                const profile = yield admin_service_1.AdminService.getAdminProfile(userId);
                res.json({
                    success: true,
                    data: profile
                });
            }
            catch (error) {
                console.error('[AdminController] Error getting profile:', error);
                res.status(500).json({
                    success: false,
                    error: 'Internal Server Error',
                    message: error.message
                });
            }
        });
    }
    static updateProfile(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId) {
                    return res.status(401).json({
                        success: false,
                        error: 'Unauthorized'
                    });
                }
                const updateData = req.body;
                const updatedProfile = yield admin_service_1.AdminService.updateAdminProfile(userId, updateData);
                res.json({
                    success: true,
                    data: updatedProfile,
                    message: 'Profile updated successfully'
                });
            }
            catch (error) {
                console.error('[AdminController] Error updating profile:', error);
                res.status(500).json({
                    success: false,
                    error: 'Internal Server Error',
                    message: error.message
                });
            }
        });
    }
    static updatePassword(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId) {
                    return res.status(401).json({
                        success: false,
                        error: 'Unauthorized'
                    });
                }
                const { currentPassword, newPassword } = req.body;
                if (!currentPassword || !newPassword) {
                    return res.status(400).json({
                        success: false,
                        error: 'Current password and new password are required'
                    });
                }
                yield admin_service_1.AdminService.updateAdminPassword(userId, currentPassword, newPassword);
                res.json({
                    success: true,
                    message: 'Password updated successfully'
                });
            }
            catch (error) {
                console.error('[AdminController] Error updating password:', error);
                res.status(400).json({
                    success: false,
                    error: error.message
                });
            }
        });
    }
    static configureCommissions(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { commissionRate, rewardPoints } = req.body;
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield admin_service_1.AdminService.configureCommissions(commissionRate, rewardPoints);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static configureRewards(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { rewardPoints, rewardType } = req.body;
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield admin_service_1.AdminService.configureRewards(rewardPoints, rewardType);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static createService(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { name, price, description } = req.body;
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield admin_service_1.AdminService.createService(name, price, description);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static createArticle(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { name, basePrice, categoryId, description } = req.body;
                const result = yield admin_service_1.AdminService.createArticle(name, basePrice, categoryId, description);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getAllServices(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield admin_service_1.AdminService.getAllServices();
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getAllArticles(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield admin_service_1.AdminService.getAllArticles();
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static updateService(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { name, price, description } = req.body;
                const serviceId = req.params.serviceId;
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield admin_service_1.AdminService.updateService(serviceId, name, price, description);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static updateArticle(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const articleId = req.params.articleId;
                const result = yield admin_service_1.AdminService.updateArticle(articleId, req.body);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static deleteService(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const serviceId = req.params.serviceId;
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield admin_service_1.AdminService.deleteService(serviceId);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static deleteArticle(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const articleId = req.params.articleId;
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const result = yield admin_service_1.AdminService.deleteArticle(articleId);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static updateAffiliateStatus(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { affiliateId } = req.params;
                const { status, isActive } = req.body;
                if (!['PENDING', 'ACTIVE', 'SUSPENDED'].includes(status)) {
                    return res.status(400).json({ error: 'Invalid status' });
                }
                const result = yield admin_service_1.AdminService.updateAffiliateStatus(affiliateId, status);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getDashboardStatistics(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const stats = yield admin_service_1.AdminService.getDashboardStatistics();
                res.json({ data: stats });
            }
            catch (error) {
                console.error('Error getting dashboard statistics:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getRevenueChartData(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                console.log('[Admin Controller] Getting revenue chart data...');
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId) {
                    console.log('[Admin Controller] Unauthorized access attempt');
                    return res.status(401).json({ error: 'Unauthorized' });
                }
                const chartData = yield admin_service_1.AdminService.getRevenueChartData();
                console.log('[Admin Controller] Revenue chart data:', chartData);
                res.json({
                    success: true,
                    data: chartData // Maintenant correctement typé avec {labels: string[], data: number[]}
                });
            }
            catch (error) {
                console.error('[Admin Controller] Error getting revenue chart data:', error);
                res.status(500).json({
                    success: false,
                    error: 'Internal Server Error',
                    message: error.message
                });
            }
        });
    }
    static createOrderForCustomer(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            try {
                const adminId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                const userRole = (_b = req.user) === null || _b === void 0 ? void 0 : _b.role;
                if (!adminId || !userRole || !['ADMIN', 'SUPER_ADMIN'].includes(userRole)) {
                    return res.status(403).json({
                        success: false,
                        message: 'Unauthorized: Only administrators can create orders for customers'
                    });
                }
                const inputData = req.body;
                if (!inputData.serviceTypeId || !inputData.addressId) {
                    return res.status(400).json({
                        success: false,
                        message: 'serviceTypeId and addressId are required'
                    });
                }
                const orderData = {
                    items: inputData.items,
                    serviceTypeId: inputData.serviceTypeId,
                    addressId: inputData.addressId,
                    collectionDate: inputData.collectionDate ? new Date(inputData.collectionDate) : undefined,
                    deliveryDate: inputData.deliveryDate ? new Date(inputData.deliveryDate) : undefined
                };
                console.log('[AdminController] Creating order for customer:', inputData.customerId);
                const order = yield admin_service_1.AdminService.createOrderForCustomer(inputData.customerId, orderData);
                return res.status(201).json({
                    success: true,
                    data: order,
                    message: 'Order created successfully'
                });
            }
            catch (error) {
                console.error('[AdminController] Error creating order:', error);
                const status = error.message.includes('not found') ? 404 : 500;
                return res.status(status).json({
                    success: false,
                    message: error.message || 'Failed to create order',
                    error: process.env.NODE_ENV === 'development' ? error : undefined
                });
            }
        });
    }
    static getAllOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const page = parseInt(req.query.page) || 1;
                const limit = parseInt(req.query.limit) || 50;
                const status = req.query.status;
                const sortField = req.query.sort_field;
                const sortOrder = req.query.sort_order;
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
                        totalPages: Math.ceil(result.total / limit)
                    }
                });
            }
            catch (error) {
                res.status(500).json({ error: 'Failed to fetch orders' });
            }
        });
    }
    static getOrdersByStatus(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const orders = yield prisma_1.default.orders.findMany();
                const counts = {};
                orders.forEach(order => {
                    const status = order.status || 'UNKNOWN';
                    counts[status] = (counts[status] || 0) + 1;
                });
                const data = counts;
                return res.json({
                    success: true,
                    data: data
                });
            }
            catch (error) {
                console.error('Error getting orders by status:', error);
                res.status(500).json({
                    success: false,
                    error: 'Failed to fetch orders by status'
                });
            }
        });
    }
}
exports.AdminController = AdminController;
