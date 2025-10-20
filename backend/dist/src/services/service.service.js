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
exports.ServiceService = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class ServiceService {
    static createService(name, price, description) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const service = yield prisma.services.create({
                    data: {
                        name,
                        price,
                        description: description || null,
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
                console.error('Create service error:', error);
                throw error;
            }
        });
    }
    static getAllServices() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const services = yield prisma.services.findMany({
                    orderBy: {
                        created_at: 'desc'
                    }
                });
                return services.map(service => {
                    var _a;
                    return ({
                        id: service.id,
                        name: service.name,
                        price: service.price || 0,
                        description: service.description || undefined,
                        createdAt: service.created_at || new Date(),
                        updatedAt: service.updated_at || new Date(),
                        service_type_id: (_a = service.service_type_id) !== null && _a !== void 0 ? _a : undefined // Corrige le type pour éviter null
                    });
                });
            }
            catch (error) {
                console.error('Get all services error:', error);
                throw error;
            }
        });
    }
    static updateService(serviceId, name, price, description, service_type_id) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const updateData = {
                    name,
                    price,
                    description: description || null,
                    updated_at: new Date()
                };
                if (service_type_id) {
                    updateData.service_type_id = service_type_id;
                }
                const service = yield prisma.services.update({
                    where: { id: serviceId },
                    data: updateData
                });
                return {
                    id: service.id,
                    name: service.name,
                    price: service.price || 0,
                    description: service.description || undefined,
                    createdAt: service.created_at || new Date(),
                    updatedAt: service.updated_at || new Date(),
                    service_type_id: (_a = service.service_type_id) !== null && _a !== void 0 ? _a : undefined
                };
            }
            catch (error) {
                console.error('Update service error:', error);
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
                console.error('Delete service error:', error);
                throw error;
            }
        });
    }
}
exports.ServiceService = ServiceService;
