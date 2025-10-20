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
exports.ServiceController = void 0;
const service_service_1 = require("../services/service.service");
const pricing_service_1 = require("../services/pricing.service");
class ServiceController {
    static createService(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { name, price, description } = req.body;
                const service = yield service_service_1.ServiceService.createService(name, price, description);
                res.json({ data: service });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getAllServices(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const services = yield service_service_1.ServiceService.getAllServices();
                return res.status(200).json({
                    success: true,
                    data: services,
                    message: 'Services retrieved successfully'
                });
            }
            catch (error) {
                console.error('Error in getAllServices controller:', error);
                return res.status(500).json({
                    success: false,
                    message: 'Failed to retrieve services',
                    error: error instanceof Error ? error.message : 'Unknown error'
                });
            }
        });
    }
    static updateService(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const serviceId = req.params.serviceId;
                const { name, price, description, service_type_id } = req.body;
                const service = yield service_service_1.ServiceService.updateService(serviceId, name, price, description, service_type_id);
                res.json({ data: service });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static deleteService(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const serviceId = req.params.serviceId;
                yield service_service_1.ServiceService.deleteService(serviceId);
                res.json({ message: 'Service deleted successfully' });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getServicePrice(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { articleId, serviceTypeId, quantity = 1, weight = null, isPremium = false } = req.body;
                const priceDetails = yield pricing_service_1.PricingService.calculatePrice({
                    articleId,
                    serviceTypeId,
                    serviceId: req.body.serviceId,
                    quantity,
                    weight,
                    isPremium
                });
                return res.json({
                    success: true,
                    data: priceDetails
                });
            }
            catch (error) {
                return res.status(400).json({
                    success: false,
                    error: error instanceof Error ? error.message : 'Unknown error'
                });
            }
        });
    }
}
exports.ServiceController = ServiceController;
