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
exports.OrderQueryService = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class OrderQueryService {
    /**
     * Retourne les commandes paginées avec le total
     */
    static getAllOrdersPaginated(_a) {
        return __awaiter(this, arguments, void 0, function* ({ page = 1, limit = 10 }) {
            // Calcul du total
            const totalItems = yield prisma.orders.count();
            const totalPages = Math.ceil(totalItems / limit);
            // Récupération des commandes paginées
            const orders = yield prisma.orders.findMany({
                skip: (page - 1) * limit,
                take: limit,
                orderBy: { createdAt: 'desc' },
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
                    order_items: {
                        include: {
                            article: {
                                include: {
                                    article_categories: true
                                }
                            }
                        }
                    }
                }
            });
            return { orders, totalItems, totalPages };
        });
    }
    static getUserOrders(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const orders = yield prisma.orders.findMany({
                    where: {
                        userId
                    },
                    include: this.orderInclude,
                    orderBy: {
                        createdAt: 'desc'
                    }
                });
                return this.formatOrders(orders);
            }
            catch (error) {
                console.error('Error fetching user orders:', error);
                throw error;
            }
        });
    }
    static getOrderDetails(orderId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const order = yield prisma.orders.findUnique({
                    where: {
                        id: orderId
                    },
                    include: this.orderInclude
                });
                if (!order) {
                    throw new Error('Order not found');
                }
                return this.formatOrder(order);
            }
            catch (error) {
                console.error('Error fetching order details:', error);
                throw error;
            }
        });
    }
    static getRecentOrders() {
        return __awaiter(this, arguments, void 0, function* (limit = 5) {
            try {
                const orders = yield prisma.orders.findMany({
                    take: limit,
                    include: this.orderInclude,
                    orderBy: {
                        createdAt: 'desc'
                    }
                });
                return this.formatOrders(orders);
            }
            catch (error) {
                console.error('Error fetching recent orders:', error);
                throw error;
            }
        });
    }
    static getOrdersByStatus() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const orders = yield prisma.orders.groupBy({
                    by: ['status'],
                    _count: {
                        status: true
                    }
                });
                return orders.reduce((acc, curr) => {
                    if (curr.status) {
                        acc[curr.status] = curr._count.status;
                    }
                    return acc;
                }, {});
            }
            catch (error) {
                console.error('Error getting orders by status:', error);
                throw error;
            }
        });
    }
    static searchOrders(params) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const where = {};
                // Déclaration globale pour les logs
                const uuidRegex = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/;
                // Recherche textuelle globale
                if (params.searchTerm) {
                    // Ajout d'un match exact sur l'id si la recherche est un UUID
                    const orFilters = [
                        { id: { contains: params.searchTerm, mode: 'insensitive' } },
                        { 'user.first_name': { contains: params.searchTerm, mode: 'insensitive' } },
                        { 'user.last_name': { contains: params.searchTerm, mode: 'insensitive' } },
                        { 'user.email': { contains: params.searchTerm, mode: 'insensitive' } },
                        { 'user.phone': { contains: params.searchTerm, mode: 'insensitive' } },
                        {
                            order_items: {
                                some: {
                                    article: {
                                        name: { contains: params.searchTerm, mode: 'insensitive' }
                                    }
                                }
                            }
                        }
                    ];
                    if (uuidRegex.test(params.searchTerm)) {
                        console.log('[OrderQueryService] Recherche par ID détectée:', params.searchTerm);
                        orFilters.unshift({ id: { equals: params.searchTerm } });
                    }
                    else {
                        console.log('[OrderQueryService] Recherche standard (pas ID):', params.searchTerm);
                    }
                    where.OR = orFilters;
                }
                // Ajout de nouveaux filtres
                where.AND = [];
                // Filtre par type de service
                if (params.serviceTypeId) {
                    where.AND.push({ service_type_id: params.serviceTypeId });
                }
                // Filtre par méthode de paiement
                if (params.paymentMethod) {
                    where.AND.push({ paymentMethod: params.paymentMethod });
                }
                // Filtre par montant
                if (params.minAmount || params.maxAmount) {
                    where.AND.push({
                        totalAmount: Object.assign(Object.assign({}, (params.minAmount && { gte: new client_1.Prisma.Decimal(params.minAmount) })), (params.maxAmount && { lte: new client_1.Prisma.Decimal(params.maxAmount) }))
                    });
                }
                // Filtre par date
                if (params.startDate || params.endDate) {
                    where.AND.push({
                        createdAt: Object.assign(Object.assign({}, (params.startDate && { gte: params.startDate })), (params.endDate && { lte: params.endDate }))
                    });
                }
                // Filtre par statut
                if (params.status) {
                    where.AND.push({ status: params.status });
                }
                // Filtre par type de commande (flash/standard)
                if (params.isFlashOrder !== undefined) {
                    where.AND.push({
                        order_metadata: {
                            is_flash_order: params.isFlashOrder
                        }
                    });
                }
                // Ajouter les nouveaux includes pour plus de détails
                const include = {
                    user: {
                        select: {
                            id: true,
                            email: true,
                            first_name: true,
                            last_name: true,
                            phone: true
                        }
                    },
                    address: true,
                    service_types: true,
                    order_items: {
                        include: {
                            article: {
                                include: {
                                    article_categories: true
                                }
                            }
                        }
                    },
                    order_metadata: true
                };
                // LOGS DEBUG
                console.log('[OrderQueryService] searchOrders params:', JSON.stringify(params, null, 2));
                console.log('[OrderQueryService] Prisma where:', JSON.stringify(where, null, 2));
                console.log('[OrderQueryService] Prisma include:', JSON.stringify(include, null, 2));
                if (params.searchTerm && uuidRegex.test(params.searchTerm)) {
                    console.log('[OrderQueryService] DEBUG: La recherche utilise un filtre exact sur l\'ID.');
                }
                // Exécuter la requête avec pagination
                const [orders, total] = yield Promise.all([
                    prisma.orders.findMany({
                        where,
                        include,
                        skip: (params.pagination.page - 1) * params.pagination.limit,
                        take: params.pagination.limit,
                        orderBy: {
                            [params.sortBy || 'createdAt']: params.sortOrder || 'desc'
                        }
                    }),
                    prisma.orders.count({ where })
                ]);
                console.log('[OrderQueryService] Prisma result orders:', orders);
                console.log('[OrderQueryService] Prisma result total:', total);
                return {
                    orders: orders.map(this.formatOrder),
                    pagination: {
                        total,
                        page: params.pagination.page,
                        limit: params.pagination.limit,
                        totalPages: Math.ceil(total / params.pagination.limit)
                    }
                };
            }
            catch (error) {
                console.error('[OrderQueryService] Search error:', error);
                throw error;
            }
        });
    }
    static formatOrder(order) {
        var _a;
        return {
            id: order.id,
            userId: order.userId,
            service_id: order.serviceId || '',
            address_id: order.addressId || '',
            status: order.status || 'PENDING',
            isRecurring: order.isRecurring || false,
            recurrenceType: order.recurrenceType || 'NONE',
            totalAmount: Number(order.totalAmount || 0),
            collectionDate: order.collectionDate ? new Date(order.collectionDate) : null,
            deliveryDate: order.deliveryDate ? new Date(order.deliveryDate) : null,
            createdAt: order.createdAt || new Date(),
            updatedAt: order.updatedAt || new Date(),
            service_type_id: order.service_type_id,
            paymentStatus: order.status,
            paymentMethod: order.paymentMethod || 'CASH',
            note: order.order_notes && order.order_notes.length > 0 ? order.order_notes[0].note : null,
            items: ((_a = order.order_items) === null || _a === void 0 ? void 0 : _a.map((item) => ({
                id: item.id,
                orderId: item.orderId,
                articleId: item.articleId,
                serviceId: item.serviceId,
                quantity: item.quantity,
                unitPrice: Number(item.unitPrice),
                isPremium: item.isPremium || false,
                article: item.article ? {
                    id: item.article.id,
                    categoryId: item.article.categoryId || '',
                    name: item.article.name,
                    description: item.article.description || undefined,
                    basePrice: Number(item.article.basePrice),
                    premiumPrice: Number(item.article.premiumPrice || 0),
                    createdAt: item.article.createdAt || new Date(),
                    updatedAt: item.article.updatedAt || new Date()
                } : undefined,
                createdAt: item.createdAt,
                updatedAt: item.updatedAt
            }))) || []
        };
    }
    static formatOrders(orders) {
        return orders.map(order => this.formatOrder(order));
    }
}
exports.OrderQueryService = OrderQueryService;
OrderQueryService.orderInclude = {
    user: {
        select: {
            id: true,
            email: true,
            first_name: true,
            last_name: true,
            phone: true,
            role: true,
            referral_code: true
        }
    },
    service_types: {
        select: {
            id: true,
            name: true,
            description: true,
            pricing_type: true
        }
    },
    address: {
        select: {
            id: true,
            name: true,
            street: true,
            city: true,
            postal_code: true,
            gps_latitude: true,
            gps_longitude: true,
            is_default: true
        }
    },
    order_items: {
        include: {
            article: {
                include: {
                    article_categories: true
                }
            }
        }
    },
    order_notes: {
        select: {
            id: true,
            note: true,
            created_at: true,
            updated_at: true
        }
    },
    order_metadata: true
};
