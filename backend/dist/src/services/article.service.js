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
exports.ArticleService = void 0;
const client_1 = require("@prisma/client");
const uuid_1 = require("uuid");
const prisma = new client_1.PrismaClient();
class ArticleService {
    static createArticle(articleData) {
        return __awaiter(this, void 0, void 0, function* () {
            const { categoryId, name, description, basePrice, premiumPrice } = articleData;
            const data = yield prisma.articles.create({
                data: {
                    id: (0, uuid_1.v4)(),
                    categoryId,
                    name,
                    description,
                    basePrice,
                    premiumPrice,
                    createdAt: new Date(),
                    updatedAt: new Date(),
                }
            });
            return {
                id: data.id,
                name: data.name,
                categoryId: data.categoryId || '',
                description: data.description || '',
                basePrice: Number(data.basePrice),
                premiumPrice: data.premiumPrice ? Number(data.premiumPrice) : 0,
                createdAt: data.createdAt || new Date(),
                updatedAt: data.updatedAt || new Date()
            };
        });
    }
    static getArticleById(articleId) {
        return __awaiter(this, void 0, void 0, function* () {
            const data = yield prisma.articles.findUnique({
                where: { id: articleId }
            });
            if (!data)
                throw new Error('Article not found');
            return {
                id: data.id,
                name: data.name,
                categoryId: data.categoryId || '',
                description: data.description || '',
                basePrice: Number(data.basePrice),
                premiumPrice: data.premiumPrice ? Number(data.premiumPrice) : 0,
                createdAt: data.createdAt || new Date(),
                updatedAt: data.updatedAt || new Date()
            };
        });
    }
    static getAllArticles() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const data = yield prisma.articles.findMany({
                    where: { isDeleted: false },
                    include: {
                        article_categories: { select: { name: true } }
                    }
                });
                return data.map(article => {
                    var _a;
                    return ({
                        id: article.id,
                        name: article.name,
                        categoryId: article.categoryId || '',
                        description: article.description || '',
                        basePrice: Number(article.basePrice),
                        premiumPrice: article.premiumPrice ? Number(article.premiumPrice) : 0,
                        createdAt: article.createdAt || new Date(),
                        updatedAt: article.updatedAt || new Date(),
                        category: ((_a = article.article_categories) === null || _a === void 0 ? void 0 : _a.name) || 'Uncategorized'
                    });
                });
            }
            catch (error) {
                console.error('Error in getAllArticles:', error);
                throw error;
            }
        });
    }
    static getArticles() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const data = yield prisma.articles.findMany({
                    include: {
                        article_categories: {
                            select: { name: true }
                        }
                    }
                });
                return data.map(article => {
                    var _a;
                    return ({
                        id: article.id,
                        name: article.name,
                        categoryId: article.categoryId || '',
                        description: article.description || '',
                        basePrice: Number(article.basePrice),
                        premiumPrice: article.premiumPrice ? Number(article.premiumPrice) : 0,
                        createdAt: article.createdAt || new Date(),
                        updatedAt: article.updatedAt || new Date(),
                        category: ((_a = article.article_categories) === null || _a === void 0 ? void 0 : _a.name) || 'Uncategorized'
                    });
                });
            }
            catch (error) {
                console.error('Error in getArticles:', error);
                throw error;
            }
        });
    }
    static getArticlesForOrder() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const data = yield prisma.articles.findMany({
                    where: { isDeleted: false },
                    include: {
                        article_categories: {
                            select: { name: true }
                        }
                    },
                    orderBy: { name: 'asc' }
                });
                return data.map(article => ({
                    id: article.id,
                    name: article.name,
                    categoryId: article.categoryId || '',
                    description: article.description || '',
                    basePrice: Number(article.basePrice),
                    premiumPrice: article.premiumPrice ? Number(article.premiumPrice) : 0,
                    createdAt: article.createdAt || new Date(),
                    updatedAt: article.updatedAt || new Date()
                }));
            }
            catch (error) {
                console.error('[ArticleService] Error getting articles for order:', error);
                throw error;
            }
        });
    }
    static getArticleWithServices(articleId) {
        return __awaiter(this, void 0, void 0, function* () {
            const data = yield prisma.articles.findUnique({
                where: { id: articleId },
                include: {
                    article_service_prices: {
                        include: {
                            service_types: {
                                select: {
                                    name: true,
                                    description: true,
                                    is_default: true
                                }
                            }
                        }
                    },
                    article_categories: {
                        select: {
                            name: true,
                            description: true
                        }
                    }
                }
            });
            if (!data)
                throw new Error('Article not found');
            return data;
        });
    }
    static updateArticleServices(articleId, serviceUpdates) {
        return __awaiter(this, void 0, void 0, function* () {
            // Mise à jour en transaction pour assurer la cohérence
            return yield prisma.$transaction((tx) => __awaiter(this, void 0, void 0, function* () {
                var _a;
                for (const update of serviceUpdates) {
                    yield tx.article_service_prices.upsert({
                        where: {
                            service_type_id_article_id_service_id: {
                                service_type_id: update.service_type_id,
                                article_id: articleId,
                                service_id: (_a = update.service_id) !== null && _a !== void 0 ? _a : ''
                            }
                        },
                        update: {
                            base_price: update.base_price,
                            premium_price: update.premium_price,
                            price_per_kg: update.price_per_kg,
                            is_available: update.is_available
                        },
                        create: {
                            article_id: articleId,
                            service_type_id: update.service_type_id,
                            base_price: update.base_price || 0,
                            premium_price: update.premium_price,
                            price_per_kg: update.price_per_kg,
                            is_available: update.is_available
                        }
                    });
                }
                return yield tx.articles.findUnique({
                    where: { id: articleId },
                    include: { article_service_prices: true }
                });
            }));
        });
    }
    static updateArticle(articleId, updateData) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const existingArticle = yield prisma.articles.findUnique({
                    where: { id: articleId }
                });
                if (!existingArticle) {
                    throw new Error('Article not found');
                }
                const updatedArticle = yield prisma.articles.update({
                    where: { id: articleId },
                    data: {
                        name: updateData.name,
                        description: updateData.description,
                        basePrice: updateData.basePrice,
                        premiumPrice: updateData.premiumPrice,
                        categoryId: updateData.categoryId,
                        updatedAt: new Date()
                    }
                });
                return updatedArticle;
            }
            catch (error) {
                console.error('[ArticleService] Error updating article:', error);
                throw error;
            }
        });
    }
    static deleteArticle(articleId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const existingArticle = yield prisma.articles.findUnique({
                    where: { id: articleId }
                });
                if (!existingArticle) {
                    throw new Error('Article not found');
                }
                yield prisma.articles.update({
                    where: { id: articleId },
                    data: {
                        isDeleted: true,
                        deletedAt: new Date()
                    }
                });
            }
            catch (error) {
                console.error('[ArticleService] Error deleting article:', error);
                throw error;
            }
        });
    }
    static getArticlesByCategory(categoryId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const data = yield prisma.articles.findMany({
                    where: {
                        categoryId: categoryId,
                        isDeleted: false
                    },
                    include: {
                        article_categories: { select: { name: true } }
                    },
                    orderBy: { name: 'asc' }
                });
                return data.map(article => {
                    var _a;
                    return ({
                        id: article.id,
                        name: article.name,
                        categoryId: article.categoryId || '',
                        description: article.description || '',
                        basePrice: Number(article.basePrice),
                        premiumPrice: article.premiumPrice ? Number(article.premiumPrice) : 0,
                        createdAt: article.createdAt || new Date(),
                        updatedAt: article.updatedAt || new Date(),
                        category: ((_a = article.article_categories) === null || _a === void 0 ? void 0 : _a.name) || 'Uncategorized'
                    });
                });
            }
            catch (error) {
                console.error('[ArticleService] Error getting articles by category:', error);
                throw error;
            }
        });
    }
    static archiveArticle(articleId, reason) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.article_archives.create({
                    data: {
                        id: (0, uuid_1.v4)(),
                        original_id: articleId
                    }
                });
            }
            catch (error) {
                console.error('[ArticleService] Error archiving article:', error);
                throw error;
            }
        });
    }
}
exports.ArticleService = ArticleService;
