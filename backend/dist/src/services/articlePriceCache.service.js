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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ArticlePriceCacheService = void 0;
const node_cache_1 = __importDefault(require("node-cache"));
const client_1 = require("@prisma/client");
const pricing_config_1 = require("../config/pricing.config");
const prisma = new client_1.PrismaClient();
class ArticlePriceCacheService {
    static getPrices(articleId, serviceTypeId) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            const cacheKey = `price_${articleId}_${serviceTypeId}`;
            let prices = this.cache.get(cacheKey);
            if (!prices) {
                try {
                    const data = yield prisma.article_service_prices.findFirst({
                        where: {
                            article_id: articleId,
                            service_type_id: serviceTypeId
                        },
                        include: {
                            service_types: true
                        }
                    });
                    if (data && data.article_id && data.service_type_id) {
                        // Construction du ServiceType avec gestion stricte des types
                        const serviceType = data.service_types ? {
                            id: data.service_types.id,
                            name: data.service_types.name,
                            description: data.service_types.description || undefined,
                            is_default: Boolean(data.service_types.is_default),
                            requires_weight: Boolean(data.service_types.requires_weight),
                            supports_premium: Boolean(data.service_types.supports_premium),
                            is_active: Boolean(data.service_types.is_active),
                            created_at: data.service_types.created_at || new Date(),
                            updated_at: data.service_types.updated_at || new Date()
                        } : undefined;
                        // Construction de l'ArticleServicePrice avec gestion stricte des types
                        prices = {
                            id: data.id,
                            article_id: data.article_id,
                            service_type_id: data.service_type_id,
                            base_price: Number(data.base_price),
                            premium_price: data.premium_price ? Number(data.premium_price) : undefined,
                            price_per_kg: data.price_per_kg ? Number(data.price_per_kg) : undefined,
                            is_available: Boolean(data.is_available),
                            created_at: ((_a = data.created_at) === null || _a === void 0 ? void 0 : _a.toISOString()) || new Date().toISOString(),
                            updated_at: ((_b = data.updated_at) === null || _b === void 0 ? void 0 : _b.toISOString()) || new Date().toISOString(),
                            service_type: serviceType
                        };
                        this.cache.set(cacheKey, prices);
                    }
                }
                catch (error) {
                    console.error('[ArticlePriceCacheService] Cache error:', error);
                    return null;
                }
            }
            return prices || null;
        });
    }
    static invalidatePrice(articleId, serviceTypeId) {
        return __awaiter(this, void 0, void 0, function* () {
            const cacheKey = `price_${articleId}_${serviceTypeId}`;
            this.cache.del(cacheKey);
        });
    }
}
exports.ArticlePriceCacheService = ArticlePriceCacheService;
ArticlePriceCacheService.cache = new node_cache_1.default({
    stdTTL: pricing_config_1.pricingConfig.cacheDuration,
    checkperiod: 120
});
