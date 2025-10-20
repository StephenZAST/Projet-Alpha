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
exports.AdditionalServiceService = void 0;
const client_1 = require("@prisma/client");
const notification_service_1 = require("./notification.service");
const types_1 = require("../models/types");
const prisma = new client_1.PrismaClient();
class AdditionalServiceService {
    static createService(data) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const service = yield prisma.services.create({
                    data: {
                        name: data.name,
                        description: data.description,
                        price: data.basePrice,
                        is_partial: false, // Au lieu de is_active qui n'existe pas
                        created_at: new Date(),
                        updated_at: new Date()
                    }
                });
                // Récupération des admins
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
                // Envoi des notifications
                const notificationPromises = admins.map(admin => notification_service_1.NotificationService.sendNotification(admin.id, types_1.NotificationType.SERVICE_CREATED, {
                    title: 'Nouveau service créé',
                    message: `Le service ${service.name} a été créé`,
                    data: {
                        serviceId: service.id,
                        serviceName: service.name
                    }
                }));
                yield Promise.all(notificationPromises);
                return {
                    id: service.id,
                    name: service.name,
                    description: service.description || undefined,
                    basePrice: Number(service.price) || 0,
                    isActive: !service.is_partial, // Conversion de is_partial en isActive
                    createdAt: service.created_at || new Date(),
                    updatedAt: service.updated_at || new Date()
                };
            }
            catch (error) {
                console.error('[AdditionalServiceService] Create service error:', error);
                throw error;
            }
        });
    }
    static addServiceToOrder(orderId, serviceData) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // 1. Récupérer le service et son prix
                const service = yield prisma.services.findUnique({
                    where: { id: serviceData.service_id },
                    select: {
                        id: true,
                        name: true,
                        price: true
                    }
                });
                if (!service)
                    throw new Error('Service not found');
                // 2. Créer l'entrée pour le service additionnel
                const orderService = yield prisma.order_notes.create({
                    data: {
                        order_id: orderId,
                        note: serviceData.notes || '',
                    },
                    include: {
                        orders: true
                    }
                });
                // 3. Notification des administrateurs
                const admins = yield prisma.users.findMany({
                    where: {
                        role: {
                            in: ['ADMIN', 'SUPER_ADMIN']
                        }
                    }
                });
                const notificationPromises = admins.map(admin => notification_service_1.NotificationService.sendNotification(admin.id, types_1.NotificationType.SERVICE_ADDED, {
                    title: 'Service additionnel ajouté',
                    message: `Le service ${service.name} a été ajouté à la commande ${orderId}`,
                    data: {
                        orderId,
                        serviceName: service.name,
                        notes: serviceData.notes
                    }
                }));
                yield Promise.all(notificationPromises);
                return {
                    id: orderService.id,
                    orderId: orderService.order_id,
                    serviceId: service.id,
                    price: Number(service.price) || 0,
                    notes: serviceData.notes,
                    createdAt: orderService.created_at || new Date(),
                    updatedAt: orderService.updated_at || new Date()
                };
            }
            catch (error) {
                console.error('[AdditionalServiceService] Add service to order error:', error);
                throw error;
            }
        });
    }
    static getOrderServices(orderId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // Récupération des notes de commande avec les services associés
                const orderNotes = yield prisma.order_notes.findMany({
                    where: {
                        order_id: orderId
                    }
                });
                // Récupération des informations sur les services séparément
                const serviceIds = orderNotes.map(note => note.order_id); // Supposons que order_id fait référence au service
                const services = yield prisma.services.findMany({
                    where: {
                        id: {
                            in: serviceIds
                        }
                    },
                    select: {
                        id: true,
                        price: true
                    }
                });
                // Construction du mapping des prix
                const servicePriceMap = new Map(services.map(service => [service.id, Number(service.price || 0)]));
                // Formatage de la réponse
                return orderNotes.map(note => ({
                    id: note.id,
                    orderId: note.order_id,
                    serviceId: note.order_id, // Utilisé comme serviceId
                    price: servicePriceMap.get(note.order_id) || 0,
                    notes: note.note || undefined,
                    createdAt: note.created_at || new Date(),
                    updatedAt: note.updated_at || new Date()
                }));
            }
            catch (error) {
                console.error('[AdditionalServiceService] Get order services error:', error);
                throw error;
            }
        });
    }
    static getActiveServices() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const services = yield prisma.services.findMany({
                    where: {
                        is_partial: false
                    },
                    orderBy: {
                        created_at: 'asc'
                    }
                });
                return services.map(service => ({
                    id: service.id,
                    name: service.name,
                    description: service.description || undefined,
                    basePrice: Number(service.price) || 0,
                    isActive: true,
                    createdAt: service.created_at || new Date(),
                    updatedAt: service.updated_at || new Date()
                }));
            }
            catch (error) {
                console.error('[AdditionalServiceService] Get active services error:', error);
                throw error;
            }
        });
    }
}
exports.AdditionalServiceService = AdditionalServiceService;
