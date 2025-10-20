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
exports.OrderQueryController = void 0;
const prisma_1 = __importDefault(require("../../config/prisma"));
const pdfkit_1 = __importDefault(require("pdfkit"));
const shared_1 = require("./shared");
const orderQuery_service_1 = require("../../services/order.service/orderQuery.service");
class OrderQueryController {
    // Endpoint dédié à la recherche par ID
    static getOrderById(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { orderId } = req.params;
                if (!orderId) {
                    return res.status(400).json({ success: false, error: 'orderId requis' });
                }
                // Recherche directe par clé primaire
                const order = yield orderQuery_service_1.OrderQueryService.getOrderDetails(orderId);
                if (!order) {
                    return res.status(404).json({ success: false, error: 'Commande non trouvée' });
                }
                res.json({ success: true, data: order });
            }
            catch (error) {
                console.error('[OrderQueryController] getOrderById error:', error);
                res.status(500).json({ success: false, error: 'Erreur serveur', message: error.message });
            }
        });
    }
    static getOrderDetails(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { orderId } = req.params;
                const order = yield prisma_1.default.orders.findUnique({
                    where: { id: orderId },
                    include: {
                        user: {
                            select: {
                                id: true,
                                first_name: true,
                                last_name: true,
                                email: true,
                                phone: true
                            }
                        },
                        service_types: {
                            select: {
                                id: true,
                                name: true,
                                description: true
                            }
                        },
                        address: true,
                        order_notes: {
                            select: {
                                id: true,
                                note: true,
                                created_at: true,
                                updated_at: true
                            }
                        }
                    }
                });
                if (!order)
                    return res.status(404).json({ error: 'Order not found' });
                const items = yield shared_1.OrderSharedMethods.getOrderItems(orderId);
                const completeOrder = Object.assign(Object.assign({}, order), { items });
                res.json({ data: completeOrder });
            }
            catch (error) {
                console.error('[OrderController] Error getting order details:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getUserOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const orders = yield prisma_1.default.orders.findMany({
                    where: { userId },
                    include: {
                        service_types: {
                            select: {
                                id: true,
                                name: true,
                                description: true
                            }
                        }
                    },
                    orderBy: { createdAt: 'desc' }
                });
                const completeOrders = yield Promise.all(orders.map((order) => __awaiter(this, void 0, void 0, function* () {
                    return (Object.assign(Object.assign({}, order), { items: yield shared_1.OrderSharedMethods.getOrderItems(order.id) }));
                })));
                res.json({ data: completeOrders });
            }
            catch (error) {
                console.error('[OrderController] Error getting user orders:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getRecentOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const limit = parseInt(((_a = req.query.limit) === null || _a === void 0 ? void 0 : _a.toString()) || '5');
                const orders = yield prisma_1.default.orders.findMany({
                    include: {
                        user: {
                            select: {
                                first_name: true,
                                last_name: true,
                                email: true
                            }
                        },
                        service_types: {
                            select: {
                                id: true,
                                name: true
                            }
                        },
                        address: true
                    },
                    orderBy: { createdAt: 'desc' },
                    take: limit
                });
                res.json({
                    success: true,
                    data: orders
                });
            }
            catch (error) {
                console.error('Error fetching recent orders:', error);
                res.status(500).json({
                    success: false,
                    error: 'Failed to fetch recent orders'
                });
            }
        });
    }
    static getOrdersByStatus(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const orders = yield prisma_1.default.orders.findMany({
                    select: { status: true },
                    where: {
                        status: {
                            not: null
                        }
                    }
                });
                const statusCount = orders.reduce((acc, order) => {
                    // Vérification que le status n'est pas null avant de l'utiliser comme index
                    if (order.status) {
                        acc[order.status] = (acc[order.status] || 0) + 1;
                    }
                    return acc;
                }, {});
                res.json({
                    success: true,
                    data: statusCount
                });
            }
            catch (error) {
                console.error('Error fetching orders by status:', error);
                res.status(500).json({
                    success: false,
                    error: 'Failed to fetch orders by status'
                });
            }
        });
    }
    static getAllOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // Récupération des paramètres de pagination
                const page = req.query.page ? parseInt(req.query.page, 10) : 1;
                const limit = req.query.limit ? parseInt(req.query.limit, 10) : 20;
                const status = req.query.status;
                const startDate = req.query.startDate;
                const endDate = req.query.endDate;
                const skip = (page - 1) * limit;
                const where = {};
                if (status)
                    where.status = status;
                if (startDate && endDate) {
                    where.createdAt = {
                        gte: new Date(startDate),
                        lte: new Date(endDate)
                    };
                }
                // Récupérer le total avant pagination
                const totalCount = yield prisma_1.default.orders.count({ where });
                // Récupérer les commandes paginées
                const orders = yield prisma_1.default.orders.findMany({
                    where,
                    include: {
                        user: {
                            select: {
                                id: true,
                                first_name: true,
                                last_name: true
                            }
                        },
                        service_types: {
                            select: {
                                id: true,
                                name: true,
                                description: true
                            }
                        }
                    },
                    skip,
                    take: limit,
                    orderBy: { createdAt: 'desc' }
                });
                // Ajouter les items à chaque commande
                const ordersWithItems = yield Promise.all(orders.map((order) => __awaiter(this, void 0, void 0, function* () {
                    return (Object.assign(Object.assign({}, order), { items: yield shared_1.OrderSharedMethods.getOrderItems(order.id) }));
                })));
                res.json({
                    data: ordersWithItems,
                    page,
                    limit,
                    total: totalCount,
                    totalPages: Math.ceil(totalCount / limit)
                });
            }
            catch (error) {
                console.error('[OrderController] Error getting all orders:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
    static generateInvoice(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { orderId } = req.params;
                const order = yield prisma_1.default.orders.findUnique({
                    where: { id: orderId },
                    include: {
                        user: {
                            select: {
                                first_name: true,
                                last_name: true,
                                email: true,
                                phone: true
                            }
                        },
                        service_types: {
                            select: {
                                name: true
                            }
                        },
                        address: true
                    }
                });
                if (!order)
                    return res.status(404).json({ error: 'Order not found' });
                const items = yield shared_1.OrderSharedMethods.getOrderItems(orderId);
                const completeOrder = Object.assign(Object.assign({}, order), { items });
                const doc = new pdfkit_1.default();
                res.setHeader('Content-Type', 'application/pdf');
                res.setHeader('Content-Disposition', `attachment; filename=invoice-${orderId}.pdf`);
                doc.pipe(res);
                doc.fontSize(25).text('Facture', 100, 50);
                doc.fontSize(12).text(`Commande: ${orderId}`, 100, 100);
                doc.end();
            }
            catch (error) {
                console.error('[OrderController] Error generating invoice:', error);
                res.status(500).json({ error: error.message });
            }
        });
    }
    static searchOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { query, searchTerm, status, startDate, endDate, minAmount, maxAmount, isFlashOrder, page = 1, limit = 10, sortBy = 'createdAt', sortOrder = 'desc' } = req.query;
                // Prendre 'searchTerm' si présent, sinon 'query'
                const globalSearch = (searchTerm !== null && searchTerm !== void 0 ? searchTerm : query);
                const searchParams = {
                    searchTerm: globalSearch,
                    status: status,
                    startDate: startDate ? new Date(startDate) : undefined,
                    endDate: endDate ? new Date(endDate) : undefined,
                    minAmount: minAmount ? Number(minAmount) : undefined,
                    maxAmount: maxAmount ? Number(maxAmount) : undefined,
                    isFlashOrder: isFlashOrder === 'true',
                    pagination: {
                        page: Number(page),
                        limit: Number(limit)
                    },
                    sortBy: sortBy,
                    sortOrder: sortOrder
                };
                const result = yield orderQuery_service_1.OrderQueryService.searchOrders(searchParams);
                res.json({
                    success: true,
                    data: result.orders,
                    pagination: result.pagination
                });
            }
            catch (error) {
                console.error('[OrderQueryController] Search error:', error);
                res.status(500).json({
                    success: false,
                    error: 'Erreur lors de la recherche des commandes',
                    message: error.message
                });
            }
        });
    }
}
exports.OrderQueryController = OrderQueryController;
OrderQueryController.getOrderItems = shared_1.OrderSharedMethods.getOrderItems;
