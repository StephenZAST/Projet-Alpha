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
exports.WeightPricingController = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class WeightPricingController {
    static create(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { minWeight, maxWeight, pricePerKg } = req.body;
                const weightPricing = yield prisma.weight_based_pricing.create({
                    data: {
                        min_weight: minWeight,
                        max_weight: maxWeight,
                        price_per_kg: pricePerKg,
                        created_at: new Date(),
                        updated_at: new Date()
                    }
                });
                res.json({
                    success: true,
                    data: weightPricing
                });
            }
            catch (error) {
                console.error('Create weight pricing error:', error);
                res.status(500).json({
                    success: false,
                    error: 'Failed to create weight pricing'
                });
            }
        });
    }
    static getAll(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const weightPricings = yield prisma.weight_based_pricing.findMany({
                    orderBy: {
                        min_weight: 'asc'
                    }
                });
                res.json({
                    success: true,
                    data: weightPricings
                });
            }
            catch (error) {
                console.error('Get weight pricings error:', error);
                res.status(500).json({
                    success: false,
                    error: 'Failed to get weight pricings'
                });
            }
        });
    }
    static update(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { id } = req.params;
                const { minWeight, maxWeight, pricePerKg } = req.body;
                const weightPricing = yield prisma.weight_based_pricing.update({
                    where: { id },
                    data: {
                        min_weight: minWeight,
                        max_weight: maxWeight,
                        price_per_kg: pricePerKg,
                        updated_at: new Date()
                    }
                });
                res.json({
                    success: true,
                    data: weightPricing
                });
            }
            catch (error) {
                console.error('Update weight pricing error:', error);
                res.status(500).json({
                    success: false,
                    error: 'Failed to update weight pricing'
                });
            }
        });
    }
    static delete(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { id } = req.params;
                yield prisma.weight_based_pricing.delete({
                    where: { id }
                });
                res.json({
                    success: true,
                    message: 'Weight pricing deleted successfully'
                });
            }
            catch (error) {
                console.error('Delete weight pricing error:', error);
                res.status(500).json({
                    success: false,
                    error: 'Failed to delete weight pricing'
                });
            }
        });
    }
    static calculatePrice(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { weight, serviceTypeId } = req.query;
                if (!weight || isNaN(Number(weight))) {
                    return res.status(400).json({
                        success: false,
                        error: 'Valid weight is required'
                    });
                }
                const weightNum = Number(weight);
                const pricing = yield prisma.weight_based_pricing.findFirst({
                    where: {
                        min_weight: {
                            lte: weightNum
                        },
                        max_weight: {
                            gte: weightNum
                        }
                    }
                });
                if (!pricing) {
                    return res.status(404).json({
                        success: false,
                        error: 'No pricing found for this weight range'
                    });
                }
                const totalPrice = weightNum * Number(pricing.price_per_kg);
                res.json({
                    success: true,
                    data: {
                        basePrice: totalPrice,
                        weight: weightNum,
                        pricePerKg: pricing.price_per_kg
                    }
                });
            }
            catch (error) {
                console.error('Calculate price error:', error);
                res.status(500).json({
                    success: false,
                    error: 'Failed to calculate price'
                });
            }
        });
    }
}
exports.WeightPricingController = WeightPricingController;
