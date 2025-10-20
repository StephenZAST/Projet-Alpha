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
exports.ServiceNotificationService = void 0;
const client_1 = require("@prisma/client");
const notification_service_1 = require("./notification.service");
const types_1 = require("../models/types");
const prisma = new client_1.PrismaClient();
class ServiceNotificationService {
    static notifyServiceChange(serviceId, changes) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const service = yield prisma.services.findUnique({
                    where: {
                        id: serviceId
                    },
                    select: {
                        name: true
                    }
                });
                if (!service)
                    throw new Error('Service not found');
                // 1. Notifier les administrateurs
                const admins = yield prisma.users.findMany({
                    where: {
                        role: {
                            in: ['ADMIN', 'SUPER_ADMIN']
                        }
                    },
                    select: {
                        id: true
                    }
                });
                if (admins.length > 0) {
                    yield Promise.all(admins.map(admin => notification_service_1.NotificationService.sendNotification(admin.id, types_1.NotificationType.SERVICE_UPDATED, {
                        title: 'Service mis à jour',
                        message: `Le service "${service.name}" a été mis à jour`,
                        data: {
                            serviceId,
                            serviceName: service.name,
                            changes
                        }
                    })));
                }
                // 2. Notifier les utilisateurs avec des commandes actives
                const activeOrders = yield prisma.orders.findMany({
                    where: {
                        serviceId,
                        status: {
                            in: ['PENDING', 'PROCESSING']
                        },
                        userId: {
                            notIn: admins.map(a => a.id)
                        }
                    },
                    select: {
                        userId: true
                    }
                });
                if (activeOrders.length > 0) {
                    const uniqueUserIds = [...new Set(activeOrders.map(order => order.userId))];
                    yield Promise.all(uniqueUserIds.map(userId => notification_service_1.NotificationService.sendNotification(userId, types_1.NotificationType.SERVICE_UPDATED, {
                        title: 'Mise à jour de service',
                        message: `Le service "${service.name}" que vous utilisez a été mis à jour`,
                        data: {
                            serviceId,
                            serviceName: service.name,
                            changes
                        }
                    })));
                }
            }
            catch (error) {
                console.error('[ServiceNotificationService] Notification error:', error);
                throw error;
            }
        });
    }
}
exports.ServiceNotificationService = ServiceNotificationService;
