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
var _a;
Object.defineProperty(exports, "__esModule", { value: true });
exports.DeliveryService = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class DeliveryService {
    static getPendingOrders(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const orders = yield prisma.orders.findMany({
                    where: {
                        userId,
                        status: 'PENDING'
                    },
                    include: {
                        service_types: true,
                        order_metadata: true,
                        user: {
                            select: {
                                id: true,
                                first_name: true,
                                last_name: true,
                                email: true,
                                phone: true
                            }
                        },
                        address: {
                            select: {
                                id: true,
                                street: true,
                                city: true,
                                postal_code: true,
                                gps_latitude: true,
                                gps_longitude: true,
                                name: true
                            }
                        },
                        order_items: {
                            include: {
                                article: {
                                    select: {
                                        id: true,
                                        name: true,
                                        article_categories: {
                                            select: {
                                                name: true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                });
                return orders;
            }
            catch (error) {
                console.error('Get pending orders error:', error);
                throw error;
            }
        });
    }
    static getAssignedOrders(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const orders = yield prisma.orders.findMany({
                    where: {
                        userId,
                        status: 'COLLECTING'
                    },
                    include: {
                        service_types: true,
                        order_metadata: true,
                        user: {
                            select: {
                                id: true,
                                first_name: true,
                                last_name: true,
                                email: true,
                                phone: true
                            }
                        },
                        address: {
                            select: {
                                id: true,
                                street: true,
                                city: true,
                                postal_code: true,
                                gps_latitude: true,
                                gps_longitude: true,
                                name: true
                            }
                        },
                        order_items: {
                            include: {
                                article: {
                                    select: {
                                        id: true,
                                        name: true,
                                        article_categories: {
                                            select: {
                                                name: true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                });
                return orders;
            }
            catch (error) {
                console.error('Get assigned orders error:', error);
                throw error;
            }
        });
    }
    static getDraftOrders(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const orders = yield prisma.orders.findMany({
                    where: {
                        userId,
                        status: 'DRAFT'
                    },
                    include: {
                        service_types: true,
                        order_metadata: true,
                        user: {
                            select: {
                                id: true,
                                first_name: true,
                                last_name: true,
                                email: true,
                                phone: true
                            }
                        },
                        address: {
                            select: {
                                id: true,
                                street: true,
                                city: true,
                                postal_code: true,
                                gps_latitude: true,
                                gps_longitude: true,
                                name: true
                            }
                        },
                        order_items: {
                            include: {
                                article: {
                                    select: {
                                        id: true,
                                        name: true,
                                        article_categories: {
                                            select: {
                                                name: true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                });
                return orders;
            }
            catch (error) {
                console.error('Get draft orders error:', error);
                throw error;
            }
        });
    }
    static getOrdersByStatus(userId, status) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const orders = yield prisma.orders.findMany({
                    where: {
                        userId,
                        status
                    },
                    include: {
                        service_types: true,
                        order_metadata: true,
                        user: {
                            select: {
                                id: true,
                                first_name: true,
                                last_name: true,
                                email: true,
                                phone: true
                            }
                        },
                        address: {
                            select: {
                                id: true,
                                street: true,
                                city: true,
                                postal_code: true,
                                gps_latitude: true,
                                gps_longitude: true,
                                name: true
                            }
                        },
                        order_items: {
                            include: {
                                article: {
                                    select: {
                                        id: true,
                                        name: true,
                                        article_categories: {
                                            select: {
                                                name: true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                });
                return orders;
            }
            catch (error) {
                console.error(`Get ${status} orders error:`, error);
                throw error;
            }
        });
    }
    static updateOrderStatus(orderId, status, userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // First check if order exists and user has access
                const existingOrder = yield prisma.orders.findFirst({
                    where: {
                        id: orderId,
                        userId
                    },
                    include: {
                        service_types: true,
                        order_metadata: true
                    }
                });
                if (!existingOrder) {
                    throw new Error('Order not found or unauthorized');
                }
                // Update the order status
                const updatedOrder = yield prisma.orders.update({
                    where: {
                        id: orderId
                    },
                    data: {
                        status,
                        updatedAt: new Date()
                    },
                    include: {
                        service_types: true,
                        order_metadata: true,
                        user: {
                            select: {
                                id: true,
                                first_name: true,
                                last_name: true,
                                email: true,
                                phone: true
                            }
                        },
                        address: {
                            select: {
                                id: true,
                                street: true,
                                city: true,
                                postal_code: true,
                                gps_latitude: true,
                                gps_longitude: true,
                                name: true
                            }
                        },
                        order_items: {
                            include: {
                                article: {
                                    select: {
                                        id: true,
                                        name: true,
                                        article_categories: {
                                            select: {
                                                name: true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                });
                return updatedOrder;
            }
            catch (error) {
                console.error('Update order status error:', error);
                throw error;
            }
        });
    }
}
exports.DeliveryService = DeliveryService;
_a = DeliveryService;
// Helper method for getting orders by any status
DeliveryService.getCOLLECTEDOrders = (userId) => _a.getOrdersByStatus(userId, 'COLLECTED');
DeliveryService.getPROCESSINGOrders = (userId) => _a.getOrdersByStatus(userId, 'PROCESSING');
DeliveryService.getREADYOrders = (userId) => _a.getOrdersByStatus(userId, 'READY');
DeliveryService.getDELIVERINGOrders = (userId) => _a.getOrdersByStatus(userId, 'DELIVERING');
DeliveryService.getDELIVEREDOrders = (userId) => _a.getOrdersByStatus(userId, 'DELIVERED');
DeliveryService.getCANCELLEDOrders = (userId) => _a.getOrdersByStatus(userId, 'CANCELLED');
