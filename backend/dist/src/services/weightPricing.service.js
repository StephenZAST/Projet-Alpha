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
exports.WeightPricingService = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class WeightPricingService {
    static createPricing(data) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // Vérifier les chevauchements (à adapter si besoin, ici on ne filtre plus par serviceTypeId)
                const hasOverlap = yield this.checkOverlappingRanges(data.min_weight, data.max_weight);
                if (hasOverlap) {
                    throw new Error('Weight ranges cannot overlap');
                }
                const pricing = yield prisma.weight_based_pricing.create({
                    data: {
                        min_weight: new client_1.Prisma.Decimal(data.min_weight),
                        max_weight: new client_1.Prisma.Decimal(data.max_weight),
                        price_per_kg: new client_1.Prisma.Decimal(data.price_per_kg),
                        created_at: new Date(),
                        updated_at: new Date()
                    }
                });
                return {
                    id: pricing.id,
                    min_weight: Number(pricing.min_weight),
                    max_weight: Number(pricing.max_weight),
                    price_per_kg: Number(pricing.price_per_kg),
                    created_at: pricing.created_at,
                    updated_at: pricing.updated_at
                };
            }
            catch (error) {
                console.error('[WeightPricingService] Create pricing error:', error);
                throw error;
            }
        });
    }
    static checkOverlappingRanges(minWeight, maxWeight) {
        return __awaiter(this, void 0, void 0, function* () {
            const existingRanges = yield prisma.weight_based_pricing.findMany({
                where: {
                    AND: [
                        { min_weight: { lte: new client_1.Prisma.Decimal(maxWeight) } },
                        { max_weight: { gte: new client_1.Prisma.Decimal(minWeight) } }
                    ]
                }
            });
            return existingRanges.length > 0;
        });
    }
    static calculatePrice(weight) {
        return __awaiter(this, void 0, void 0, function* () {
            const pricing = yield prisma.weight_based_pricing.findFirst({
                where: {
                    AND: [
                        { min_weight: { lte: weight } },
                        { max_weight: { gt: weight } }
                    ]
                }
            });
            if (!pricing) {
                throw new Error('No pricing found for this weight range');
            }
            return Number(pricing.price_per_kg) * weight;
        });
    }
    static getAll() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                return yield prisma.weight_based_pricing.findMany({
                    orderBy: {
                        min_weight: 'asc'
                    }
                });
            }
            catch (error) {
                console.error('Get all weight pricing error:', error);
                throw error;
            }
        });
    }
    static create(data) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                return yield prisma.weight_based_pricing.create({
                    data: {
                        min_weight: data.minWeight,
                        max_weight: data.maxWeight,
                        price_per_kg: data.pricePerKg
                    }
                });
            }
            catch (error) {
                console.error('Create weight pricing error:', error);
                throw error;
            }
        });
    }
    static update(id, data) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                return yield prisma.weight_based_pricing.update({
                    where: { id },
                    data: {
                        min_weight: data.minWeight,
                        max_weight: data.maxWeight,
                        price_per_kg: data.pricePerKg,
                        updated_at: new Date()
                    }
                });
            }
            catch (error) {
                console.error('Update weight pricing error:', error);
                throw error;
            }
        });
    }
    static delete(id) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                return yield prisma.weight_based_pricing.delete({
                    where: { id }
                });
            }
            catch (error) {
                console.error('Delete weight pricing error:', error);
                throw error;
            }
        });
    }
    static findByWeight(weight) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                return yield prisma.weight_based_pricing.findFirst({
                    where: {
                        AND: [
                            { min_weight: { lte: weight } },
                            { max_weight: { gte: weight } }
                        ]
                    }
                });
            }
            catch (error) {
                console.error('Find by weight error:', error);
                throw error;
            }
        });
    }
}
exports.WeightPricingService = WeightPricingService;
