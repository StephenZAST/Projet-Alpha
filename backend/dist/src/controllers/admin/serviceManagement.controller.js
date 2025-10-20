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
exports.ServiceManagementController = void 0;
const article_service_1 = require("../../services/article.service");
const serviceType_service_1 = require("../../services/serviceType.service");
class ServiceManagementController {
    static updateArticleServices(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { articleId } = req.params;
                const serviceUpdates = req.body;
                const updatedServices = yield article_service_1.ArticleService.updateArticleServices(articleId, serviceUpdates);
                res.json({
                    success: true,
                    data: updatedServices
                });
            }
            catch (error) {
                console.error('[ServiceManagementController] Update error:', error);
                res.status(400).json({
                    success: false,
                    message: error.message
                });
            }
        });
    }
    static getServiceConfiguration(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const [serviceTypes, defaultService] = yield Promise.all([
                    serviceType_service_1.ServiceTypeService.getAll(true), // Utilisation de getAll au lieu de getAllServiceTypes
                    serviceType_service_1.ServiceTypeService.getDefaultServiceType()
                ]);
                res.json({
                    success: true,
                    data: {
                        serviceTypes,
                        defaultService,
                        configuration: {
                            allowPricePerKg: process.env.ALLOW_PRICE_PER_KG === 'true',
                            allowPremiumPrices: process.env.ALLOW_PREMIUM_PRICES === 'true'
                        }
                    }
                });
            }
            catch (error) {
                console.error('[ServiceManagementController] Configuration error:', error);
                res.status(500).json({
                    success: false,
                    message: 'Failed to fetch service configuration',
                    error: error.message
                });
            }
        });
    }
    static setDefaultServiceType(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { serviceTypeId } = req.params;
                // Utilisation de getDefaultServiceType au lieu de setDefaultServiceType
                const currentDefault = yield serviceType_service_1.ServiceTypeService.getDefaultServiceType();
                // Si un type de service par défaut existe déjà, mettre à jour son statut
                if (currentDefault) {
                    yield serviceType_service_1.ServiceTypeService.updateServiceType(currentDefault.id, {
                        is_default: false
                    });
                }
                // Mettre à jour le nouveau type de service par défaut
                const defaultService = yield serviceType_service_1.ServiceTypeService.updateServiceType(serviceTypeId, {
                    is_default: true
                });
                res.json({
                    success: true,
                    data: defaultService
                });
            }
            catch (error) {
                console.error('[ServiceManagementController] Error setting default service type:', error);
                res.status(500).json({
                    success: false,
                    error: 'Failed to set default service type'
                });
            }
        });
    }
}
exports.ServiceManagementController = ServiceManagementController;
