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
exports.DefaultServiceService = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class DefaultServiceService {
    static setDefaultService(categoryId_1, serviceId_1) {
        return __awaiter(this, arguments, void 0, function* (categoryId, serviceId, restrictions = []) {
            var _a;
            try {
                // Mettre à jour ou créer le service par défaut
                const data = yield prisma.service_types.upsert({
                    where: {
                        id: serviceId
                    },
                    update: {
                        is_default: true,
                        updated_at: new Date()
                    },
                    create: {
                        id: serviceId,
                        name: '', // Requis par le schéma
                        is_default: true,
                        created_at: new Date(),
                        updated_at: new Date()
                    },
                    include: {
                        services: true
                    }
                });
                // Désactiver les autres services par défaut de la catégorie
                yield prisma.service_types.updateMany({
                    where: {
                        id: {
                            not: serviceId
                        }
                    },
                    data: {
                        is_default: false,
                        updated_at: new Date()
                    }
                });
                return {
                    id: data.id,
                    serviceId: data.id,
                    categoryId,
                    restrictions,
                    service: (_a = data.services) === null || _a === void 0 ? void 0 : _a[0],
                    updatedAt: data.updated_at
                };
            }
            catch (error) {
                console.error('[DefaultServiceService] Set default service error:', error);
                throw error;
            }
        });
    }
    static getDefaultServices(categoryId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const services = yield prisma.service_types.findMany({
                    where: {
                        is_default: true
                    },
                    include: {
                        services: true
                    }
                });
                return services.map(service => {
                    var _a;
                    return ({
                        id: service.id,
                        serviceId: service.id,
                        categoryId,
                        service: (_a = service.services) === null || _a === void 0 ? void 0 : _a[0],
                        restrictions: [],
                        updatedAt: service.updated_at
                    });
                });
            }
            catch (error) {
                console.error('[DefaultServiceService] Get default services error:', error);
                throw error;
            }
        });
    }
    static removeDefaultService(categoryId, serviceId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.service_types.update({
                    where: {
                        id: serviceId
                    },
                    data: {
                        is_default: false,
                        updated_at: new Date()
                    }
                });
            }
            catch (error) {
                console.error('[DefaultServiceService] Remove default service error:', error);
                throw error;
            }
        });
    }
}
exports.DefaultServiceService = DefaultServiceService;
