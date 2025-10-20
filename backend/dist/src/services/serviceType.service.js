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
exports.ServiceTypeService = void 0;
const client_1 = require("@prisma/client");
const types_1 = require("../models/types");
const notification_service_1 = require("./notification.service");
const prisma = new client_1.PrismaClient();
class ServiceTypeService {
    static create(data) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const serviceType = yield prisma.service_types.create({
                    data: {
                        name: data.name,
                        description: data.description || null,
                        is_default: data.is_default || false,
                        requires_weight: data.requires_weight || false,
                        supports_premium: data.supports_premium || false,
                        created_at: new Date(),
                        updated_at: new Date(),
                        is_active: true
                    }
                });
                // Notify all admins (UUID réel)
                const admins = yield prisma.users.findMany({
                    where: { role: { in: ['ADMIN', 'SUPER_ADMIN'] } },
                    select: { id: true }
                });
                yield Promise.all(admins.map(admin => notification_service_1.NotificationService.sendNotification(admin.id, types_1.NotificationType.SERVICE_TYPE_CREATED, {
                    serviceTypeId: serviceType.id,
                    name: serviceType.name
                })));
                return {
                    id: serviceType.id,
                    name: serviceType.name,
                    description: serviceType.description || undefined,
                    is_default: serviceType.is_default || false,
                    requires_weight: serviceType.requires_weight || false,
                    supports_premium: serviceType.supports_premium || false,
                    is_active: serviceType.is_active || false,
                    created_at: serviceType.created_at || new Date(),
                    updated_at: serviceType.updated_at || new Date(),
                    pricing_type: serviceType.requires_weight ? 'WEIGHT_BASED' : 'FIXED'
                };
            }
            catch (error) {
                console.error('Error creating service type:', error);
                throw error;
            }
        });
    }
    static update(id, data) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const serviceType = yield prisma.service_types.update({
                    where: { id },
                    data: Object.assign(Object.assign({}, data), { updated_at: new Date() })
                });
                // Notify all admins (UUID réel)
                const admins = yield prisma.users.findMany({
                    where: { role: { in: ['ADMIN', 'SUPER_ADMIN'] } },
                    select: { id: true }
                });
                yield Promise.all(admins.map(admin => notification_service_1.NotificationService.sendNotification(admin.id, types_1.NotificationType.SERVICE_TYPE_UPDATED, {
                    serviceTypeId: serviceType.id,
                    name: serviceType.name,
                    changes: data
                })));
                return {
                    id: serviceType.id,
                    name: serviceType.name,
                    description: serviceType.description || undefined,
                    is_default: serviceType.is_default || false,
                    requires_weight: serviceType.requires_weight || false,
                    supports_premium: serviceType.supports_premium || false,
                    is_active: serviceType.is_active || false,
                    created_at: serviceType.created_at || new Date(),
                    updated_at: serviceType.updated_at || new Date(),
                    pricing_type: serviceType.requires_weight ? 'WEIGHT_BASED' : 'FIXED'
                };
            }
            catch (error) {
                console.error('Error updating service type:', error);
                throw error;
            }
        });
    }
    static updateServiceType(id, data) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const updatedServiceType = yield prisma.service_types.update({
                    where: { id },
                    data: Object.assign(Object.assign({}, data), { updated_at: new Date() })
                });
                return {
                    id: updatedServiceType.id,
                    name: updatedServiceType.name,
                    description: updatedServiceType.description || undefined,
                    is_default: updatedServiceType.is_default || false,
                    requires_weight: updatedServiceType.requires_weight || false,
                    supports_premium: updatedServiceType.supports_premium || false,
                    is_active: updatedServiceType.is_active || false,
                    created_at: updatedServiceType.created_at || new Date(),
                    updated_at: updatedServiceType.updated_at || new Date(),
                    pricing_type: updatedServiceType.requires_weight ? 'WEIGHT_BASED' : 'FIXED'
                };
            }
            catch (error) {
                console.error('Error updating service type:', error);
                throw error;
            }
        });
    }
    static delete(id) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.service_types.delete({
                    where: { id }
                });
            }
            catch (error) {
                console.error('Error deleting service type:', error);
                throw error;
            }
        });
    }
    static getById(id) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const serviceType = yield prisma.service_types.findUnique({
                    where: { id }
                });
                if (!serviceType)
                    return null;
                return {
                    id: serviceType.id,
                    name: serviceType.name,
                    description: serviceType.description || undefined,
                    is_default: serviceType.is_default || false,
                    requires_weight: serviceType.requires_weight || false,
                    supports_premium: serviceType.supports_premium || false,
                    is_active: serviceType.is_active || false,
                    created_at: serviceType.created_at || new Date(),
                    updated_at: serviceType.updated_at || new Date(),
                    pricing_type: serviceType.requires_weight ? 'WEIGHT_BASED' : 'FIXED'
                };
            }
            catch (error) {
                console.error('Error getting service type:', error);
                throw error;
            }
        });
    }
    static getAll() {
        return __awaiter(this, arguments, void 0, function* (includeInactive = false) {
            try {
                const serviceTypes = yield prisma.service_types.findMany({
                    where: includeInactive ? undefined : {
                        is_active: true
                    },
                    orderBy: {
                        name: 'asc'
                    }
                });
                return serviceTypes.map(st => ({
                    id: st.id,
                    name: st.name,
                    description: st.description || undefined,
                    is_default: st.is_default || false,
                    requires_weight: st.requires_weight || false,
                    supports_premium: st.supports_premium || false,
                    is_active: st.is_active || false,
                    created_at: st.created_at || new Date(),
                    updated_at: st.updated_at || new Date(),
                    pricing_type: st.requires_weight ? 'WEIGHT_BASED' : 'FIXED'
                }));
            }
            catch (error) {
                console.error('Error getting service types:', error);
                throw error;
            }
        });
    }
    static getDefaultServiceType() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const serviceType = yield prisma.service_types.findFirst({
                    where: {
                        is_default: true,
                        is_active: true
                    }
                });
                if (!serviceType)
                    return null;
                return {
                    id: serviceType.id,
                    name: serviceType.name,
                    description: serviceType.description || undefined,
                    is_default: serviceType.is_default || false,
                    requires_weight: serviceType.requires_weight || false,
                    supports_premium: serviceType.supports_premium || false,
                    is_active: serviceType.is_active || false,
                    created_at: serviceType.created_at || new Date(),
                    updated_at: serviceType.updated_at || new Date(),
                    pricing_type: serviceType.requires_weight ? 'WEIGHT_BASED' : 'FIXED'
                };
            }
            catch (error) {
                console.error('Error getting default service type:', error);
                throw error;
            }
        });
    }
}
exports.ServiceTypeService = ServiceTypeService;
