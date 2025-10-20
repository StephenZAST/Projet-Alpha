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
exports.OrderMapController = void 0;
const prisma_1 = __importDefault(require("../../config/prisma"));
class OrderMapController {
    /**
     * Récupère les commandes avec leurs coordonnées GPS pour affichage sur carte
     */
    static getOrdersForMap(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { status, startDate, endDate, collectionDateStart, collectionDateEnd, deliveryDateStart, deliveryDateEnd, isFlashOrder, serviceTypeId, paymentMethod, city, postalCode, bounds // Pour limiter aux commandes dans la zone visible de la carte
                 } = req.query;
                console.log('[OrderMapController] Getting orders for map with filters:', {
                    status,
                    startDate,
                    endDate,
                    collectionDateStart,
                    collectionDateEnd,
                    deliveryDateStart,
                    deliveryDateEnd,
                    isFlashOrder,
                    serviceTypeId,
                    paymentMethod,
                    city,
                    postalCode,
                    bounds
                });
                // Construction des filtres
                const whereClause = {
                    // Exclure les commandes sans adresse ou sans coordonnées GPS
                    address: {
                        AND: [
                            { gps_latitude: { not: null } },
                            { gps_longitude: { not: null } }
                        ]
                    }
                };
                // Filtre par statut
                if (status && status !== 'all') {
                    whereClause.status = status.toString().toUpperCase();
                }
                // Filtre par date de création
                if (startDate || endDate) {
                    whereClause.createdAt = {};
                    if (startDate) {
                        whereClause.createdAt.gte = new Date(startDate);
                    }
                    if (endDate) {
                        whereClause.createdAt.lte = new Date(endDate);
                    }
                }
                // Filtre par date de collecte
                if (collectionDateStart || collectionDateEnd) {
                    whereClause.collectionDate = {};
                    if (collectionDateStart) {
                        whereClause.collectionDate.gte = new Date(collectionDateStart);
                    }
                    if (collectionDateEnd) {
                        whereClause.collectionDate.lte = new Date(collectionDateEnd);
                    }
                }
                // Filtre par date de livraison
                if (deliveryDateStart || deliveryDateEnd) {
                    whereClause.deliveryDate = {};
                    if (deliveryDateStart) {
                        whereClause.deliveryDate.gte = new Date(deliveryDateStart);
                    }
                    if (deliveryDateEnd) {
                        whereClause.deliveryDate.lte = new Date(deliveryDateEnd);
                    }
                }
                // Filtre commande flash
                if (isFlashOrder !== undefined) {
                    whereClause.order_metadata = {
                        is_flash_order: isFlashOrder === 'true'
                    };
                }
                // Filtre par type de service
                if (serviceTypeId && serviceTypeId !== 'all') {
                    whereClause.service_type_id = serviceTypeId;
                }
                // Filtre par méthode de paiement
                if (paymentMethod && paymentMethod !== 'all') {
                    whereClause.paymentMethod = paymentMethod;
                }
                // Filtre par ville
                if (city) {
                    whereClause.address.city = {
                        contains: city,
                        mode: 'insensitive'
                    };
                }
                // Filtre par code postal
                if (postalCode) {
                    whereClause.address.postal_code = {
                        contains: postalCode
                    };
                }
                // Filtre par bounds de la carte (optionnel pour optimiser les performances)
                if (bounds) {
                    try {
                        const boundsObj = JSON.parse(bounds);
                        if (boundsObj.north && boundsObj.south && boundsObj.east && boundsObj.west) {
                            whereClause.address.AND.push({
                                gps_latitude: {
                                    gte: parseFloat(boundsObj.south),
                                    lte: parseFloat(boundsObj.north)
                                }
                            });
                            whereClause.address.AND.push({
                                gps_longitude: {
                                    gte: parseFloat(boundsObj.west),
                                    lte: parseFloat(boundsObj.east)
                                }
                            });
                        }
                    }
                    catch (e) {
                        console.warn('[OrderMapController] Invalid bounds format:', bounds);
                    }
                }
                // Récupération des commandes avec leurs données essentielles
                const orders = yield prisma_1.default.orders.findMany({
                    where: whereClause,
                    select: {
                        id: true,
                        status: true,
                        totalAmount: true,
                        createdAt: true,
                        collectionDate: true,
                        deliveryDate: true,
                        paymentMethod: true,
                        affiliateCode: true,
                        address: {
                            select: {
                                id: true,
                                name: true,
                                street: true,
                                city: true,
                                postal_code: true,
                                gps_latitude: true,
                                gps_longitude: true
                            }
                        },
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
                        order_metadata: {
                            select: {
                                is_flash_order: true,
                                metadata: true
                            }
                        },
                        order_items: {
                            select: {
                                id: true,
                                quantity: true,
                                unitPrice: true,
                                isPremium: true,
                                weight: true,
                                article: {
                                    select: {
                                        id: true,
                                        name: true,
                                        description: true
                                    }
                                }
                            }
                        }
                    },
                    orderBy: {
                        createdAt: 'desc'
                    },
                    // Limiter le nombre de résultats pour éviter la surcharge
                    take: 1000
                });
                // Transformation des données pour la carte
                const mapOrders = orders.map((order) => {
                    var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k;
                    return ({
                        id: order.id,
                        status: order.status,
                        totalAmount: order.totalAmount,
                        createdAt: order.createdAt,
                        collectionDate: order.collectionDate,
                        deliveryDate: order.deliveryDate,
                        paymentMethod: order.paymentMethod,
                        affiliateCode: order.affiliateCode,
                        isFlashOrder: ((_a = order.order_metadata) === null || _a === void 0 ? void 0 : _a.is_flash_order) || false,
                        coordinates: {
                            latitude: parseFloat(((_c = (_b = order.address) === null || _b === void 0 ? void 0 : _b.gps_latitude) === null || _c === void 0 ? void 0 : _c.toString()) || '0'),
                            longitude: parseFloat(((_e = (_d = order.address) === null || _d === void 0 ? void 0 : _d.gps_longitude) === null || _e === void 0 ? void 0 : _e.toString()) || '0')
                        },
                        address: {
                            id: (_f = order.address) === null || _f === void 0 ? void 0 : _f.id,
                            name: (_g = order.address) === null || _g === void 0 ? void 0 : _g.name,
                            street: (_h = order.address) === null || _h === void 0 ? void 0 : _h.street,
                            city: (_j = order.address) === null || _j === void 0 ? void 0 : _j.city,
                            postalCode: (_k = order.address) === null || _k === void 0 ? void 0 : _k.postal_code
                        },
                        client: {
                            id: order.user.id,
                            firstName: order.user.first_name,
                            lastName: order.user.last_name,
                            email: order.user.email,
                            phone: order.user.phone
                        },
                        serviceType: {
                            id: order.service_types.id,
                            name: order.service_types.name,
                            description: order.service_types.description
                        },
                        itemsCount: order.order_items.length,
                        totalWeight: order.order_items.reduce((sum, item) => { var _a; return sum + (parseFloat(((_a = item.weight) === null || _a === void 0 ? void 0 : _a.toString()) || '0')); }, 0),
                        items: order.order_items.map((item) => ({
                            id: item.id,
                            quantity: item.quantity,
                            unitPrice: item.unitPrice,
                            isPremium: item.isPremium,
                            weight: item.weight,
                            article: {
                                id: item.article.id,
                                name: item.article.name,
                                description: item.article.description
                            }
                        }))
                    });
                });
                // Statistiques pour la carte
                const stats = {
                    total: mapOrders.length,
                    byStatus: mapOrders.reduce((acc, order) => {
                        acc[order.status] = (acc[order.status] || 0) + 1;
                        return acc;
                    }, {}),
                    byPaymentMethod: mapOrders.reduce((acc, order) => {
                        acc[order.paymentMethod] = (acc[order.paymentMethod] || 0) + 1;
                        return acc;
                    }, {}),
                    flashOrders: mapOrders.filter((o) => o.isFlashOrder).length,
                    totalAmount: mapOrders.reduce((sum, order) => { var _a; return sum + parseFloat(((_a = order.totalAmount) === null || _a === void 0 ? void 0 : _a.toString()) || '0'); }, 0)
                };
                console.log(`[OrderMapController] Found ${mapOrders.length} orders for map display`);
                res.json({
                    success: true,
                    data: {
                        orders: mapOrders,
                        stats,
                        count: mapOrders.length
                    }
                });
            }
            catch (error) {
                console.error('[OrderMapController] Error getting orders for map:', error);
                res.status(500).json({
                    success: false,
                    error: 'Erreur lors de la récupération des commandes pour la carte',
                    message: error.message
                });
            }
        });
    }
    /**
     * Récupère les statistiques géographiques des commandes
     */
    static getOrdersGeoStats(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { status, startDate, endDate, isFlashOrder } = req.query;
                console.log('[OrderMapController] Getting geo stats with filters:', {
                    status,
                    startDate,
                    endDate,
                    isFlashOrder
                });
                const whereClause = {
                    address: {
                        AND: [
                            { gps_latitude: { not: null } },
                            { gps_longitude: { not: null } }
                        ]
                    }
                };
                // Appliquer les mêmes filtres que pour getOrdersForMap
                if (status && status !== 'all') {
                    whereClause.status = status.toString().toUpperCase();
                }
                if (startDate || endDate) {
                    whereClause.createdAt = {};
                    if (startDate) {
                        whereClause.createdAt.gte = new Date(startDate);
                    }
                    if (endDate) {
                        whereClause.createdAt.lte = new Date(endDate);
                    }
                }
                if (isFlashOrder !== undefined) {
                    whereClause.order_metadata = {
                        is_flash_order: isFlashOrder === 'true'
                    };
                }
                // Statistiques par ville
                const cityStats = yield prisma_1.default.orders.groupBy({
                    by: ['addressId'],
                    where: whereClause,
                    _count: {
                        id: true
                    },
                    _sum: {
                        totalAmount: true
                    }
                });
                // Récupérer les détails des adresses pour les villes
                const addressIds = cityStats.map((stat) => stat.addressId).filter(Boolean);
                const addresses = yield prisma_1.default.addresses.findMany({
                    where: {
                        id: { in: addressIds }
                    },
                    select: {
                        id: true,
                        city: true,
                        gps_latitude: true,
                        gps_longitude: true
                    }
                });
                // Grouper par ville
                const cityStatsMap = new Map();
                cityStats.forEach((stat) => {
                    var _a, _b, _c;
                    const address = addresses.find((addr) => addr.id === stat.addressId);
                    if (address && address.city) {
                        const city = address.city;
                        if (!cityStatsMap.has(city)) {
                            cityStatsMap.set(city, {
                                city,
                                count: 0,
                                totalAmount: 0,
                                coordinates: {
                                    latitude: parseFloat(((_a = address.gps_latitude) === null || _a === void 0 ? void 0 : _a.toString()) || '0'),
                                    longitude: parseFloat(((_b = address.gps_longitude) === null || _b === void 0 ? void 0 : _b.toString()) || '0')
                                }
                            });
                        }
                        const cityData = cityStatsMap.get(city);
                        cityData.count += stat._count.id;
                        cityData.totalAmount += parseFloat(((_c = stat._sum.totalAmount) === null || _c === void 0 ? void 0 : _c.toString()) || '0');
                    }
                });
                const geoStats = {
                    byCity: Array.from(cityStatsMap.values()),
                    totalCities: cityStatsMap.size,
                    totalOrders: cityStats.reduce((sum, stat) => sum + stat._count.id, 0),
                    totalAmount: cityStats.reduce((sum, stat) => { var _a; return sum + parseFloat(((_a = stat._sum.totalAmount) === null || _a === void 0 ? void 0 : _a.toString()) || '0'); }, 0)
                };
                res.json({
                    success: true,
                    data: geoStats
                });
            }
            catch (error) {
                console.error('[OrderMapController] Error getting geo stats:', error);
                res.status(500).json({
                    success: false,
                    error: 'Erreur lors de la récupération des statistiques géographiques',
                    message: error.message
                });
            }
        });
    }
}
exports.OrderMapController = OrderMapController;
