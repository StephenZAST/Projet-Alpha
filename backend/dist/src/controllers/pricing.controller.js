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
exports.PricingController = void 0;
const pricing_service_1 = require("../services/pricing.service");
class PricingController {
    static calculatePrice(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const priceParams = {
                    articleId: req.body.articleId,
                    serviceTypeId: req.body.serviceTypeId,
                    serviceId: req.body.serviceId,
                    quantity: req.body.quantity,
                    weight: req.body.weight,
                    isPremium: req.body.isPremium
                };
                const priceDetails = yield pricing_service_1.PricingService.calculatePrice(priceParams);
                res.json({
                    success: true,
                    data: priceDetails
                });
            }
            catch (error) {
                console.error('[PricingController] Calculate price error:', error);
                res.status(400).json({
                    success: false,
                    error: error instanceof Error ? error.message : 'Unknown error'
                });
            }
        });
    }
    static getPricingConfiguration(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { serviceTypeId } = req.params;
                const { data: pricing, error } = yield pricing_service_1.PricingService.getPricingConfiguration(serviceTypeId);
                if (error)
                    throw error;
                res.json({
                    success: true,
                    data: pricing
                });
            }
            catch (error) {
                console.error('[PricingController] Get pricing configuration error:', error);
                res.status(400).json({
                    success: false,
                    error: error instanceof Error ? error.message : 'Unknown error'
                });
            }
        });
    }
}
exports.PricingController = PricingController;
