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
exports.ArticleCategoryService = void 0;
const client_1 = require("@prisma/client");
const uuid_1 = require("uuid");
const prisma = new client_1.PrismaClient();
class ArticleCategoryService {
    static createArticleCategory(categoryData) {
        return __awaiter(this, void 0, void 0, function* () {
            const { name, description } = categoryData;
            const data = yield prisma.article_categories.create({
                data: {
                    id: (0, uuid_1.v4)(),
                    name,
                    description,
                    createdAt: new Date()
                }
            });
            return {
                id: data.id,
                name: data.name,
                description: data.description || undefined,
                createdAt: data.createdAt || new Date()
            };
        });
    }
    static getArticleCategoryById(categoryId) {
        return __awaiter(this, void 0, void 0, function* () {
            const data = yield prisma.article_categories.findUnique({
                where: { id: categoryId }
            });
            if (!data)
                throw new Error('Article category not found');
            return {
                id: data.id,
                name: data.name,
                description: data.description || undefined,
                createdAt: data.createdAt || new Date()
            };
        });
    }
    static getAllArticleCategories() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // Récupère toutes les catégories et compte les articles associés
                const categories = yield prisma.article_categories.findMany({
                    orderBy: { name: 'asc' },
                    include: { articles: true }
                });
                return categories.map(category => ({
                    id: category.id,
                    name: category.name,
                    description: category.description || undefined,
                    createdAt: category.createdAt || new Date(),
                    articlesCount: category.articles ? category.articles.length : 0
                }));
            }
            catch (error) {
                console.error('Error in getAllCategories:', error);
                throw error;
            }
        });
    }
    static updateArticleCategory(categoryId, categoryData) {
        return __awaiter(this, void 0, void 0, function* () {
            const data = yield prisma.article_categories.update({
                where: { id: categoryId },
                data: {
                    name: categoryData.name,
                    description: categoryData.description
                }
            });
            if (!data)
                throw new Error('Article category not found');
            return {
                id: data.id,
                name: data.name,
                description: data.description || undefined,
                createdAt: data.createdAt || new Date()
            };
        });
    }
    static deleteArticleCategory(categoryId) {
        return __awaiter(this, void 0, void 0, function* () {
            yield prisma.article_categories.delete({
                where: { id: categoryId }
            });
        });
    }
}
exports.ArticleCategoryService = ArticleCategoryService;
