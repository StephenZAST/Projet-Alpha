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
exports.ServiceTypeController = void 0;
const serviceType_service_1 = require("../services/serviceType.service");
class ServiceTypeController {
    static createServiceType(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const serviceType = yield serviceType_service_1.ServiceTypeService.create(req.body);
            res.status(201).json({
                success: true,
                data: serviceType
            });
        });
    }
    static updateServiceType(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { id } = req.params;
            const serviceType = yield serviceType_service_1.ServiceTypeService.update(id, req.body);
            res.json({
                success: true,
                data: serviceType
            });
        });
    }
    static deleteServiceType(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { id } = req.params;
            yield serviceType_service_1.ServiceTypeService.delete(id);
            res.json({
                success: true,
                message: 'Service type deleted successfully'
            });
        });
    }
    static getServiceType(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const { id } = req.params;
            const serviceType = yield serviceType_service_1.ServiceTypeService.getById(id);
            res.json({
                success: true,
                data: serviceType
            });
        });
    }
    static getAllServiceTypes(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            const includeInactive = req.query.includeInactive === 'true';
            const serviceTypes = yield serviceType_service_1.ServiceTypeService.getAll(includeInactive);
            res.json({
                success: true,
                data: serviceTypes
            });
        });
    }
}
exports.ServiceTypeController = ServiceTypeController;
