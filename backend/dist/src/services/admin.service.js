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
exports.AdminService = void 0;
const client_1 = require("@prisma/client");
const types_1 = require("../models/types");
const notification_service_1 = require("./notification.service");
const prisma = new client_1.PrismaClient();
class AdminService {
    static createService(name, price, description) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const service = yield prisma.services.create({
                    data: {
                        name,
                        price,
                        description,
                        created_at: new Date(),
                        updated_at: new Date()
                    }
                });
                return {
                    id: service.id,
                    name: service.name,
                    price: service.price || 0,
                    description: service.description || undefined,
                    createdAt: service.created_at || new Date(),
                    updatedAt: service.updated_at || new Date()
                };
            }
            catch (error) {
                console.error('[AdminService] Create service error:', error);
                throw error;
            }
        });
    }
    static getAllServices() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const services = yield prisma.services.findMany({
                    include: {
                        service_types: true
                    }
                });
                return services.map(service => ({
                    id: service.id,
                    name: service.name,
                    price: service.price || 0,
                    description: service.description || undefined,
                    createdAt: service.created_at || new Date(),
                    updatedAt: service.updated_at || new Date()
                }));
            }
            catch (error) {
                console.error('[AdminService] Get all services error:', error);
                throw error;
            }
        });
    }
    static updateService(serviceId, name, price, description) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const service = yield prisma.services.update({
                    where: { id: serviceId },
                    data: {
                        name,
                        price,
                        description,
                        updated_at: new Date()
                    }
                });
                return {
                    id: service.id,
                    name: service.name,
                    price: service.price || 0,
                    description: service.description || undefined,
                    createdAt: service.created_at || new Date(),
                    updatedAt: service.updated_at || new Date()
                };
            }
            catch (error) {
                console.error('[AdminService] Update service error:', error);
                throw error;
            }
        });
    }
    static deleteService(serviceId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.services.delete({
                    where: { id: serviceId }
                });
            }
            catch (error) {
                console.error('[AdminService] Delete service error:', error);
                throw error;
            }
        });
    }
    static createArticle(name, basePrice, categoryId, description) {
        return __awaiter(this, void 0, void 0, function* () {
            return yield prisma.articles.create({
                data: {
                    name,
                    basePrice,
                    categoryId,
                    description
                }
            });
        });
    }
    static getAllArticles() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const articles = yield prisma.articles.findMany({
                    where: {
                        isDeleted: false
                    },
                    include: {
                        article_categories: true
                    },
                    orderBy: {
                        createdAt: 'desc'
                    }
                });
                return articles.map(article => ({
                    id: article.id,
                    name: article.name,
                    categoryId: article.categoryId || '',
                    description: article.description || undefined,
                    basePrice: Number(article.basePrice),
                    premiumPrice: Number(article.premiumPrice || 0),
                    createdAt: article.createdAt || new Date(),
                    updatedAt: article.updatedAt || new Date()
                }));
            }
            catch (error) {
                console.error('[AdminService] Get all articles error:', error);
                throw error;
            }
        });
    }
    static updateArticle(articleId, data) {
        return __awaiter(this, void 0, void 0, function* () {
            return yield prisma.articles.update({
                where: { id: articleId },
                data
            });
        });
    }
    static deleteArticle(articleId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.articles.update({
                    where: { id: articleId },
                    data: {
                        isDeleted: true,
                        updatedAt: new Date()
                    }
                });
            }
            catch (error) {
                console.error('[AdminService] Delete article error:', error);
                throw error;
            }
        });
    }
    static getDashboardStatistics() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const [totalOrders, totalRevenue, totalCustomers, recentOrders] = yield Promise.all([
                    prisma.orders.count(),
                    prisma.orders.aggregate({
                        _sum: {
                            totalAmount: true
                        },
                        where: {
                            status: 'DELIVERED'
                        }
                    }),
                    prisma.users.count({
                        where: {
                            role: 'CLIENT'
                        }
                    }),
                    prisma.orders.findMany({
                        take: 5,
                        orderBy: {
                            createdAt: 'desc'
                        },
                        include: {
                            user: {
                                select: {
                                    id: true,
                                    email: true,
                                    first_name: true,
                                    last_name: true
                                }
                            },
                            order_items: {
                                include: {
                                    article: true
                                }
                            },
                            service_types: true
                        }
                    })
                ]);
                const ordersByStatus = yield prisma.orders.groupBy({
                    by: ['status'],
                    _count: true
                });
                const statusCounts = ordersByStatus.reduce((acc, curr) => {
                    if (curr.status) {
                        acc[curr.status] = curr._count;
                    }
                    return acc;
                }, {});
                return {
                    totalOrders,
                    totalRevenue: Number(totalRevenue._sum.totalAmount || 0),
                    totalCustomers,
                    recentOrders: recentOrders.map(order => {
                        var _a;
                        return ({
                            id: order.id,
                            totalAmount: Number(order.totalAmount || 0),
                            status: order.status || 'PENDING',
                            createdAt: order.createdAt || new Date(),
                            service: {
                                name: ((_a = order.service_types) === null || _a === void 0 ? void 0 : _a.name) || ''
                            },
                            user: order.user ? {
                                id: order.user.id,
                                email: order.user.email,
                                firstName: order.user.first_name,
                                lastName: order.user.last_name
                            } : null
                        });
                    }),
                    ordersByStatus: statusCounts
                };
            }
            catch (error) {
                console.error('[AdminService] Get dashboard statistics error:', error);
                throw error;
            }
        });
    }
    static updateAffiliateStatus(affiliateId, status) {
        return __awaiter(this, void 0, void 0, function* () {
            return yield prisma.affiliate_profiles.update({
                where: { id: affiliateId },
                data: { status: status }
            });
        });
    }
    static configureCommissions(commissionRate, rewardPoints) {
        return __awaiter(this, void 0, void 0, function* () {
            return yield prisma.affiliate_levels.create({
                data: {
                    name: 'Default',
                    minEarnings: 0,
                    commissionRate: commissionRate
                }
            });
        });
    }
    static configureRewards(rewardPoints, rewardType) {
        return __awaiter(this, void 0, void 0, function* () {
            return yield prisma.price_configurations.create({
                data: {
                    id: 'rewards_config',
                }
            });
        });
    }
    static getAllOrders(page, limit, params) {
        return __awaiter(this, void 0, void 0, function* () {
            const skip = (page - 1) * limit;
            // Construction dynamique du filtre avancé
            const where = {};
            // Statut (inclut le filtre flash si combiné)
            if (params === null || params === void 0 ? void 0 : params.status) {
                where.status = params.status;
            }
            // Type de commande flash (statut DRAFT)
            if (typeof (params === null || params === void 0 ? void 0 : params.isFlashOrder) === 'boolean') {
                if (params.isFlashOrder) {
                    where.status = 'DRAFT';
                }
                else {
                    if (!params.status) {
                        where.status = { not: 'DRAFT' };
                    }
                }
            }
            // Type de service dynamique
            if (params === null || params === void 0 ? void 0 : params.serviceTypeId) {
                where.service_type_id = params.serviceTypeId;
            }
            // Méthode de paiement
            if (params === null || params === void 0 ? void 0 : params.paymentMethod) {
                where.paymentMethod = params.paymentMethod;
            }
            // Statut de paiement supprimé (non présent dans le modèle)
            // Code affilié
            if (params === null || params === void 0 ? void 0 : params.affiliateCode) {
                where.affiliateCode = params.affiliateCode;
            }
            // Type de récurrence
            if (params === null || params === void 0 ? void 0 : params.recurrenceType) {
                where.recurrenceType = params.recurrenceType;
            }
            // Ville
            if (params === null || params === void 0 ? void 0 : params.city) {
                where.address = Object.assign(Object.assign({}, where.address), { city: { contains: params.city, mode: 'insensitive' } });
            }
            // Code postal
            if (params === null || params === void 0 ? void 0 : params.postalCode) {
                where.address = Object.assign(Object.assign({}, where.address), { postal_code: { contains: params.postalCode, mode: 'insensitive' } });
            }
            // Plage de dates de collecte
            if (params === null || params === void 0 ? void 0 : params.collectionDateStart) {
                where.collectionDate = Object.assign(Object.assign({}, where.collectionDate), { gte: new Date(params.collectionDateStart) });
            }
            if (params === null || params === void 0 ? void 0 : params.collectionDateEnd) {
                where.collectionDate = Object.assign(Object.assign({}, where.collectionDate), { lte: new Date(params.collectionDateEnd) });
            }
            // Plage de dates de livraison
            if (params === null || params === void 0 ? void 0 : params.deliveryDateStart) {
                where.deliveryDate = Object.assign(Object.assign({}, where.deliveryDate), { gte: new Date(params.deliveryDateStart) });
            }
            if (params === null || params === void 0 ? void 0 : params.deliveryDateEnd) {
                where.deliveryDate = Object.assign(Object.assign({}, where.deliveryDate), { lte: new Date(params.deliveryDateEnd) });
            }
            // Commande récurrente
            if (typeof (params === null || params === void 0 ? void 0 : params.isRecurring) === 'boolean') {
                where.isRecurring = params.isRecurring;
            }
            // Montant
            if (params === null || params === void 0 ? void 0 : params.minAmount) {
                where.totalAmount = Object.assign(Object.assign({}, where.totalAmount), { gte: Number(params.minAmount) });
            }
            if (params === null || params === void 0 ? void 0 : params.maxAmount) {
                where.totalAmount = Object.assign(Object.assign({}, where.totalAmount), { lte: Number(params.maxAmount) });
            }
            // Recherche globale (sur user, email, etc.)
            if (params === null || params === void 0 ? void 0 : params.query) {
                where.OR = [
                    {
                        user: {
                            is: {
                                OR: [
                                    { first_name: { contains: params.query, mode: 'insensitive' } },
                                    { last_name: { contains: params.query, mode: 'insensitive' } },
                                    { email: { contains: params.query, mode: 'insensitive' } }
                                ]
                            }
                        }
                    }
                ];
            }
            // Gestion du tri par date de récurrence si demandé
            let orderBy = (params === null || params === void 0 ? void 0 : params.sortField) ? {
                [params.sortField]: params.sortOrder || 'desc'
            } : { createdAt: 'desc' };
            if (params === null || params === void 0 ? void 0 : params.sortByNextRecurrenceDate) {
                orderBy = { nextRecurrenceDate: params.sortByNextRecurrenceDate };
            }
            const orders = yield prisma.orders.findMany({
                skip,
                take: limit,
                where,
                orderBy,
                include: {
                    user: true,
                    order_items: {
                        include: {
                            article: true
                        }
                    },
                    address: true
                }
            });
            const total = yield prisma.orders.count({ where });
            return {
                orders,
                total,
                pages: Math.ceil(total / limit)
            };
        });
    }
    static createOrderForCustomer(userId, orderData) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const user = yield prisma.users.findUnique({
                    where: { id: userId }
                });
                if (!user)
                    throw new Error('User not found');
                const order = yield prisma.orders.create({
                    data: {
                        userId,
                        service_type_id: orderData.serviceTypeId,
                        addressId: orderData.addressId,
                        status: 'PENDING',
                        collectionDate: orderData.collectionDate,
                        deliveryDate: orderData.deliveryDate,
                        createdAt: new Date(),
                        updatedAt: new Date(),
                        order_items: {
                            create: orderData.items.map(item => ({
                                articleId: item.articleId,
                                quantity: item.quantity,
                                serviceId: orderData.serviceTypeId,
                                unitPrice: 0,
                                createdAt: new Date(),
                                updatedAt: new Date()
                            }))
                        }
                    },
                    include: {
                        order_items: {
                            include: {
                                article: true
                            }
                        }
                    }
                });
                yield notification_service_1.NotificationService.sendNotification(userId, types_1.NotificationType.ORDER_CREATED, {
                    title: 'Nouvelle commande créée',
                    message: `Votre commande #${order.id} a été créée avec succès`,
                    data: { orderId: order.id }
                });
                return order;
            }
            catch (error) {
                console.error('[AdminService] Create order for customer error:', error);
                throw error;
            }
        });
    }
    static getRevenueChartData() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const revenue = yield prisma.orders.findMany({
                    where: {
                        status: 'DELIVERED'
                    },
                    select: {
                        createdAt: true,
                        totalAmount: true
                    },
                    orderBy: {
                        createdAt: 'asc'
                    }
                });
                const chartData = revenue.reduce((acc, order) => {
                    var _a;
                    const date = ((_a = order.createdAt) === null || _a === void 0 ? void 0 : _a.toISOString().split('T')[0]) || '';
                    const amount = Number(order.totalAmount || 0);
                    const dateIndex = acc.labels.indexOf(date);
                    if (dateIndex === -1) {
                        acc.labels.push(date);
                        acc.data.push(amount);
                    }
                    else {
                        acc.data[dateIndex] += amount;
                    }
                    return acc;
                }, { labels: [], data: [] });
                return chartData;
            }
            catch (error) {
                console.error('[AdminService] Get revenue chart data error:', error);
                return { labels: [], data: [] };
            }
        });
    }
    static getStatistics() {
        return __awaiter(this, void 0, void 0, function* () {
            const [orders, totalRevenue, totalCustomers, recentOrders, orderStatusCounts] = yield Promise.all([
                prisma.orders.count(),
                prisma.orders.aggregate({
                    _sum: {
                        totalAmount: true
                    },
                    where: {
                        status: 'DELIVERED'
                    }
                }),
                prisma.users.count({
                    where: {
                        role: 'CLIENT'
                    }
                }),
                prisma.orders.findMany({
                    take: 5,
                    orderBy: {
                        createdAt: 'desc'
                    },
                    include: {
                        user: true,
                        service_types: true
                    }
                }),
                prisma.orders.groupBy({
                    by: ['status'],
                    _count: true
                })
            ]);
            const statusCounts = orderStatusCounts.reduce((acc, curr) => {
                if (curr.status) {
                    acc[curr.status] = curr._count;
                }
                return acc;
            }, {});
            return {
                totalOrders: orders,
                totalRevenue: Number(totalRevenue._sum.totalAmount || 0),
                totalCustomers,
                recentOrders,
                ordersByStatus: statusCounts
            };
        });
    }
    static getAdminProfile(adminId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                console.log('[AdminService] Looking for user with ID:', adminId);
                // Chercher l'utilisateur sans restriction de rôle d'abord
                const user = yield prisma.users.findUnique({
                    where: { id: adminId },
                    select: {
                        id: true,
                        email: true,
                        first_name: true,
                        last_name: true,
                        phone: true,
                        role: true,
                        created_at: true,
                        updated_at: true
                    }
                });
                console.log('[AdminService] User found:', user);
                if (!user) {
                    throw new Error(`User with ID ${adminId} not found`);
                }
                // Vérifier que l'utilisateur a un rôle d'administration (plus flexible)
                const adminRoles = ['ADMIN', 'SUPER_ADMIN']; // On peut ajouter d'autres rôles si nécessaire
                if (!adminRoles.includes(user.role)) {
                    console.log(`[AdminService] User ${user.email} has role ${user.role}, which is not an admin role`);
                    throw new Error(`User ${user.email} does not have admin privileges`);
                }
                console.log('[AdminService] Admin profile loaded successfully for:', user.email);
                return {
                    id: user.id,
                    email: user.email,
                    firstName: user.first_name || '',
                    lastName: user.last_name || '',
                    phone: user.phone || '',
                    role: user.role,
                    createdAt: user.created_at || new Date(),
                    updatedAt: user.updated_at || new Date()
                };
            }
            catch (error) {
                console.error('[AdminService] Get admin profile error:', error);
                throw error;
            }
        });
    }
    static updateAdminProfile(adminId, data) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const updateData = {
                    updated_at: new Date()
                };
                if (data.firstName !== undefined)
                    updateData.first_name = data.firstName;
                if (data.lastName !== undefined)
                    updateData.last_name = data.lastName;
                if (data.phone !== undefined)
                    updateData.phone = data.phone;
                if (data.email !== undefined)
                    updateData.email = data.email;
                const admin = yield prisma.users.update({
                    where: {
                        id: adminId
                        // Pas de restriction de rôle ici - la validation est faite au niveau du middleware d'autorisation
                    },
                    data: updateData,
                    select: {
                        id: true,
                        email: true,
                        first_name: true,
                        last_name: true,
                        phone: true,
                        role: true,
                        created_at: true,
                        updated_at: true
                    }
                });
                return {
                    id: admin.id,
                    email: admin.email,
                    firstName: admin.first_name || '',
                    lastName: admin.last_name || '',
                    phone: admin.phone || '',
                    role: admin.role,
                    createdAt: admin.created_at || new Date(),
                    updatedAt: admin.updated_at || new Date()
                };
            }
            catch (error) {
                console.error('[AdminService] Update admin profile error:', error);
                throw error;
            }
        });
    }
    static updateAdminPassword(adminId, currentPassword, newPassword) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // First verify current password
                const admin = yield prisma.users.findUnique({
                    where: {
                        id: adminId
                        // Pas de restriction de rôle ici - la validation est faite au niveau du middleware d'autorisation
                    },
                    select: {
                        id: true,
                        password: true
                    }
                });
                if (!admin) {
                    throw new Error('Admin not found');
                }
                // Import bcrypt for password verification
                const bcrypt = require('bcrypt');
                const isCurrentPasswordValid = yield bcrypt.compare(currentPassword, admin.password);
                if (!isCurrentPasswordValid) {
                    throw new Error('Current password is incorrect');
                }
                // Hash new password
                const saltRounds = 10;
                const hashedNewPassword = yield bcrypt.hash(newPassword, saltRounds);
                // Update password
                yield prisma.users.update({
                    where: { id: adminId },
                    data: {
                        password: hashedNewPassword,
                        updated_at: new Date()
                    }
                });
                return { success: true, message: 'Password updated successfully' };
            }
            catch (error) {
                console.error('[AdminService] Update admin password error:', error);
                throw error;
            }
        });
    }
}
exports.AdminService = AdminService;
