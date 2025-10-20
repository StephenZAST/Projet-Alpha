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
exports.ArticleServicePriceService = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class ArticleServicePriceService {
    // Retourne tous les couples article/serviceType disponibles avec prix, filtré par where
    static getCouples(where) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const data = yield prisma.article_service_prices.findMany({
                    where,
                    include: {
                        articles: true,
                        service_types: true,
                        services: true
                    }
                });
                // Format enrichi pour le frontend
                return data.map((item) => {
                    var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k, _l, _m, _o, _p, _q, _r, _s;
                    return ({
                        id: item.id,
                        article_id: item.article_id,
                        service_type_id: item.service_type_id,
                        service_id: (_a = item.service_id) !== null && _a !== void 0 ? _a : '',
                        base_price: item.base_price !== null ? Number(item.base_price) : null,
                        premium_price: item.premium_price !== null ? Number(item.premium_price) : null,
                        price_per_kg: item.price_per_kg !== null ? Number(item.price_per_kg) : null,
                        is_available: item.is_available,
                        created_at: item.created_at,
                        updated_at: item.updated_at,
                        article_name: (_c = (_b = item.articles) === null || _b === void 0 ? void 0 : _b.name) !== null && _c !== void 0 ? _c : '',
                        article_description: (_e = (_d = item.articles) === null || _d === void 0 ? void 0 : _d.description) !== null && _e !== void 0 ? _e : '',
                        service_type_name: (_g = (_f = item.service_types) === null || _f === void 0 ? void 0 : _f.name) !== null && _g !== void 0 ? _g : '',
                        service_type_description: (_j = (_h = item.service_types) === null || _h === void 0 ? void 0 : _h.description) !== null && _j !== void 0 ? _j : '',
                        service_type_pricing_type: (_l = (_k = item.service_types) === null || _k === void 0 ? void 0 : _k.pricing_type) !== null && _l !== void 0 ? _l : '',
                        service_type_requires_weight: (_o = (_m = item.service_types) === null || _m === void 0 ? void 0 : _m.requires_weight) !== null && _o !== void 0 ? _o : false,
                        service_type_supports_premium: (_q = (_p = item.service_types) === null || _p === void 0 ? void 0 : _p.supports_premium) !== null && _q !== void 0 ? _q : false,
                        service_name: (_s = (_r = item.services) === null || _r === void 0 ? void 0 : _r.name) !== null && _s !== void 0 ? _s : '',
                    });
                });
            }
            catch (error) {
                console.error('Error getting couples:', error);
                throw error;
            }
        });
    }
    static create(data) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            return yield prisma.article_service_prices.create({
                data: {
                    article_id: data.article_id,
                    service_type_id: data.service_type_id,
                    service_id: (_a = data.service_id) !== null && _a !== void 0 ? _a : null,
                    base_price: data.base_price,
                    premium_price: data.premium_price,
                    price_per_kg: data.price_per_kg,
                    is_available: data.is_available
                }
            });
        });
    }
    static update(id, data) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            return yield prisma.article_service_prices.update({
                where: { id },
                data: Object.assign(Object.assign({}, data), { service_id: (_a = data.service_id) !== null && _a !== void 0 ? _a : undefined })
            });
        });
    }
    static getByArticleId(articleId) {
        return __awaiter(this, void 0, void 0, function* () {
            return yield prisma.article_service_prices.findMany({
                where: { article_id: articleId },
                include: {
                    service_types: true
                }
            });
        });
    }
    static delete(id) {
        return __awaiter(this, void 0, void 0, function* () {
            return yield prisma.article_service_prices.delete({
                where: { id }
            });
        });
    }
    static setPrices(articleId, serviceTypeId, priceData) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b, _c;
            try {
                const price = yield prisma.article_service_prices.upsert({
                    where: {
                        service_type_id_article_id_service_id: {
                            service_type_id: serviceTypeId,
                            article_id: articleId,
                            service_id: (_a = priceData.service_id) !== null && _a !== void 0 ? _a : ''
                        }
                    },
                    update: {
                        base_price: priceData.base_price ? new client_1.Prisma.Decimal(priceData.base_price) : undefined,
                        premium_price: priceData.premium_price ? new client_1.Prisma.Decimal(priceData.premium_price) : null,
                        price_per_kg: priceData.price_per_kg ? new client_1.Prisma.Decimal(priceData.price_per_kg) : null,
                        is_available: priceData.is_available,
                        service_id: (_b = priceData.service_id) !== null && _b !== void 0 ? _b : undefined,
                        updated_at: new Date()
                    },
                    create: {
                        article_id: articleId,
                        service_type_id: serviceTypeId,
                        service_id: (_c = priceData.service_id) !== null && _c !== void 0 ? _c : null,
                        base_price: new client_1.Prisma.Decimal(priceData.base_price || 0),
                        premium_price: priceData.premium_price ? new client_1.Prisma.Decimal(priceData.premium_price) : null,
                        price_per_kg: priceData.price_per_kg ? new client_1.Prisma.Decimal(priceData.price_per_kg) : null,
                        is_available: priceData.is_available,
                        created_at: new Date(),
                        updated_at: new Date()
                    },
                    include: {
                        service_types: true
                    }
                });
                return this.formatArticleServicePrice(price);
            }
            catch (error) {
                console.error('[ArticleServicePriceService] Set prices error:', error);
                throw error;
            }
        });
    }
    static getAllPrices() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const data = yield prisma.article_service_prices.findMany();
                const result = yield Promise.all(data.map((item) => __awaiter(this, void 0, void 0, function* () {
                    var _a, _b, _c, _d;
                    // Récupérer les entités associées
                    const articlePromise = item.article_id ? prisma.articles.findUnique({ where: { id: item.article_id } }) : null;
                    const serviceTypePromise = item.service_type_id ? prisma.service_types.findUnique({ where: { id: item.service_type_id } }) : null;
                    const servicePromise = item.service_id ? prisma.services.findUnique({ where: { id: item.service_id } }) : null;
                    const [article, serviceType, service] = yield Promise.all([
                        articlePromise,
                        serviceTypePromise,
                        servicePromise
                    ]);
                    return {
                        id: item.id,
                        article_id: item.article_id,
                        service_type_id: item.service_type_id,
                        service_id: (_a = item.service_id) !== null && _a !== void 0 ? _a : '',
                        base_price: item.base_price,
                        premium_price: item.premium_price,
                        price_per_kg: item.price_per_kg,
                        is_available: item.is_available,
                        created_at: item.created_at,
                        updated_at: item.updated_at,
                        article_name: (_b = article === null || article === void 0 ? void 0 : article.name) !== null && _b !== void 0 ? _b : '',
                        service_type_name: (_c = serviceType === null || serviceType === void 0 ? void 0 : serviceType.name) !== null && _c !== void 0 ? _c : '',
                        service_name: (_d = service === null || service === void 0 ? void 0 : service.name) !== null && _d !== void 0 ? _d : ''
                    };
                })));
                return result;
            }
            catch (error) {
                console.error('Error getting all prices:', error);
                throw error;
            }
        });
    }
    static getArticlePrices(articleId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const data = yield prisma.article_service_prices.findMany({
                    where: {
                        article_id: articleId
                    },
                    include: {
                        service_types: true,
                        services: true,
                        articles: true
                    }
                });
                // Formater les données pour inclure les noms
                return data.map((item) => {
                    var _a, _b, _c, _d, _e, _f, _g;
                    return ({
                        id: item.id,
                        article_id: item.article_id,
                        service_type_id: item.service_type_id,
                        service_id: (_a = item.service_id) !== null && _a !== void 0 ? _a : '',
                        base_price: item.base_price,
                        premium_price: item.premium_price,
                        price_per_kg: item.price_per_kg,
                        is_available: item.is_available,
                        created_at: item.created_at,
                        updated_at: item.updated_at,
                        article_name: (_c = (_b = item.articles) === null || _b === void 0 ? void 0 : _b.name) !== null && _c !== void 0 ? _c : '',
                        service_type_name: (_e = (_d = item.service_types) === null || _d === void 0 ? void 0 : _d.name) !== null && _e !== void 0 ? _e : '',
                        service_name: (_g = (_f = item.services) === null || _f === void 0 ? void 0 : _f.name) !== null && _g !== void 0 ? _g : ''
                    });
                });
            }
            catch (error) {
                console.error('Error getting article prices:', error);
                throw error;
            }
        });
    }
    static formatArticleServicePrice(data) {
        var _a;
        return {
            id: data.id,
            article_id: data.article_id,
            service_type_id: data.service_type_id,
            service_id: (_a = data.service_id) !== null && _a !== void 0 ? _a : '',
            base_price: Number(data.base_price),
            premium_price: data.premium_price ? Number(data.premium_price) : undefined,
            price_per_kg: data.price_per_kg ? Number(data.price_per_kg) : undefined,
            is_available: data.is_available,
            created_at: data.created_at,
            updated_at: data.updated_at,
            service_type: data.service_types || undefined
        };
    }
}
exports.ArticleServicePriceService = ArticleServicePriceService;
