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
exports.ClientOrderQueryService = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
/**
 * 📱 Service de requêtes de commandes pour le CLIENT APP
 *
 * Ce service est spécifiquement conçu pour l'application client mobile
 * et enrichit les données avec des informations supplémentaires comme
 * le compteur d'articles, sans perturber les autres applications.
 */
class ClientOrderQueryService {
    /**
     * Récupère les commandes d'un utilisateur avec enrichissement pour le client
     * Ajoute automatiquement le compteur d'articles (itemsCount)
     */
    static getUserOrdersEnriched(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const orders = yield prisma.orders.findMany({
                    where: {
                        userId
                    },
                    include: {
                        user: {
                            select: {
                                id: true,
                                email: true,
                                first_name: true,
                                last_name: true,
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
                    },
                    orderBy: {
                        createdAt: 'desc'
                    }
                });
                // Enrichir chaque commande avec le compteur d'articles
                return Promise.all(orders.map(order => this.enrichOrderForClient(order)));
            }
            catch (error) {
                console.error('[ClientOrderQueryService] Error fetching user orders:', error);
                throw error;
            }
        });
    }
    /**
     * Récupère une commande par ID avec enrichissement pour le client
     */
    static getOrderByIdEnriched(orderId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const order = yield prisma.orders.findUnique({
                    where: {
                        id: orderId
                    },
                    include: {
                        user: {
                            select: {
                                id: true,
                                email: true,
                                first_name: true,
                                last_name: true,
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
                    }
                });
                if (!order) {
                    throw new Error('Order not found');
                }
                return this.enrichOrderForClient(order);
            }
            catch (error) {
                console.error('[ClientOrderQueryService] Error fetching order details:', error);
                throw error;
            }
        });
    }
    /**
     * Récupère les commandes récentes avec enrichissement
     */
    static getRecentOrdersEnriched(userId_1) {
        return __awaiter(this, arguments, void 0, function* (userId, limit = 5) {
            try {
                const orders = yield prisma.orders.findMany({
                    where: {
                        userId
                    },
                    take: limit,
                    include: {
                        user: {
                            select: {
                                id: true,
                                email: true,
                                first_name: true,
                                last_name: true,
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
                        },
                        order_metadata: true
                    },
                    orderBy: {
                        createdAt: 'desc'
                    }
                });
                return Promise.all(orders.map(order => this.enrichOrderForClient(order)));
            }
            catch (error) {
                console.error('[ClientOrderQueryService] Error fetching recent orders:', error);
                throw error;
            }
        });
    }
    /**
     * Enrichit une commande avec des données supplémentaires pour le client
     * - Ajoute itemsCount (nombre d'articles)
     * - Formate les items avec les noms d'articles
     * - Ajoute des métadonnées utiles
     */
    static enrichOrderForClient(order) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            console.log('[ClientOrderQueryService] 🔄 Enriching order:', order.id);
            console.log('[ClientOrderQueryService] 📦 Raw order_items count:', ((_a = order.order_items) === null || _a === void 0 ? void 0 : _a.length) || 0);
            // 🔍 Récupérer les services pour chaque item
            const itemsWithServices = yield Promise.all((order.order_items || []).map((item, index) => __awaiter(this, void 0, void 0, function* () {
                var _a, _b;
                console.log(`[ClientOrderQueryService] 🔍 Item ${index + 1}:`, {
                    itemId: item.id,
                    serviceId: item.serviceId,
                    articleName: (_a = item.article) === null || _a === void 0 ? void 0 : _a.name
                });
                // Récupérer le service associé à cet item
                const service = yield prisma.services.findUnique({
                    where: { id: item.serviceId },
                    select: {
                        id: true,
                        name: true,
                        description: true,
                        service_type_id: true,
                        service_types: {
                            select: {
                                id: true,
                                name: true,
                                description: true
                            }
                        }
                    }
                });
                console.log(`[ClientOrderQueryService] 📋 Service found for item ${index + 1}:`, {
                    serviceId: service === null || service === void 0 ? void 0 : service.id,
                    serviceName: service === null || service === void 0 ? void 0 : service.name,
                    serviceTypeName: (_b = service === null || service === void 0 ? void 0 : service.service_types) === null || _b === void 0 ? void 0 : _b.name
                });
                return {
                    id: item.id,
                    orderId: item.orderId,
                    articleId: item.articleId,
                    serviceId: item.serviceId,
                    quantity: item.quantity,
                    unitPrice: Number(item.unitPrice),
                    isPremium: item.isPremium || false,
                    weight: item.weight ? Number(item.weight) : null,
                    // 🎯 Informations de l'article
                    article: item.article ? {
                        id: item.article.id,
                        categoryId: item.article.categoryId || '',
                        name: item.article.name,
                        description: item.article.description || undefined,
                        basePrice: Number(item.article.basePrice),
                        premiumPrice: Number(item.article.premiumPrice || 0),
                        category: item.article.article_categories ? {
                            id: item.article.article_categories.id,
                            name: item.article.article_categories.name,
                            description: item.article.article_categories.description
                        } : null,
                        createdAt: item.article.createdAt || new Date(),
                        updatedAt: item.article.updatedAt || new Date()
                    } : null,
                    // ✅ Informations du service (nouveau)
                    service: service ? {
                        id: service.id,
                        name: service.name,
                        description: service.description,
                        serviceTypeId: service.service_type_id,
                        serviceType: service.service_types ? {
                            id: service.service_types.id,
                            name: service.service_types.name,
                            description: service.service_types.description
                        } : null
                    } : null,
                    createdAt: item.createdAt,
                    updatedAt: item.updatedAt
                };
            })));
            const items = itemsWithServices;
            return {
                id: order.id,
                userId: order.userId,
                addressId: order.addressId,
                affiliateCode: order.affiliateCode,
                status: order.status || 'PENDING',
                isRecurring: order.isRecurring || false,
                recurrenceType: order.recurrenceType || 'NONE',
                nextRecurrenceDate: order.nextRecurrenceDate,
                totalAmount: Number(order.totalAmount || 0),
                collectionDate: order.collectionDate,
                deliveryDate: order.deliveryDate,
                createdAt: order.createdAt || new Date(),
                updatedAt: order.updatedAt || new Date(),
                serviceId: order.serviceId,
                service_type_id: order.service_type_id,
                paymentMethod: order.paymentMethod || 'CASH',
                // 🎯 Données enrichies pour le client
                itemsCount: items.length, // ✅ Compteur d'articles
                items: items,
                // Relations
                user: order.user ? {
                    id: order.user.id,
                    email: order.user.email,
                    first_name: order.user.first_name,
                    last_name: order.user.last_name,
                    phone: order.user.phone
                } : null,
                service_types: order.service_types ? {
                    id: order.service_types.id,
                    name: order.service_types.name,
                    description: order.service_types.description
                } : null,
                address: order.address ? {
                    id: order.address.id,
                    name: order.address.name,
                    street: order.address.street,
                    city: order.address.city,
                    postal_code: order.address.postal_code,
                    gps_latitude: order.address.gps_latitude ? Number(order.address.gps_latitude) : null,
                    gps_longitude: order.address.gps_longitude ? Number(order.address.gps_longitude) : null,
                    is_default: order.address.is_default
                } : null,
                order_metadata: order.order_metadata,
                note: order.order_notes && order.order_notes.length > 0
                    ? order.order_notes[0].note
                    : null
            };
        });
    }
}
exports.ClientOrderQueryService = ClientOrderQueryService;
