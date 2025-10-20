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
exports.BlogCategoryService = void 0;
const client_1 = require("@prisma/client");
const uuid_1 = require("uuid");
const prisma = new client_1.PrismaClient();
class BlogCategoryService {
    static createCategory(name, description) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const newCategory = yield prisma.blog_categories.create({
                    data: {
                        id: (0, uuid_1.v4)(),
                        name,
                        description: description || null,
                        created_at: new Date(),
                        updated_at: new Date() // On garde dans la BD mais pas dans le retour
                    }
                });
                return {
                    id: newCategory.id,
                    name: newCategory.name,
                    description: newCategory.description || undefined,
                    createdAt: newCategory.created_at ? new Date(newCategory.created_at) : new Date()
                };
            }
            catch (error) {
                console.error('Create category error:', error);
                throw error;
            }
        });
    }
    static getAllCategories() {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const categories = yield prisma.blog_categories.findMany({
                    orderBy: {
                        created_at: 'desc'
                    }
                });
                return categories.map(category => ({
                    id: category.id,
                    name: category.name,
                    description: category.description || undefined,
                    createdAt: category.created_at ? new Date(category.created_at) : new Date()
                }));
            }
            catch (error) {
                console.error('Get all categories error:', error);
                throw error;
            }
        });
    }
    static updateCategory(categoryId, name, description) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const updatedCategory = yield prisma.blog_categories.update({
                    where: {
                        id: categoryId
                    },
                    data: {
                        name,
                        description: description || null,
                        updated_at: new Date()
                    }
                });
                return {
                    id: updatedCategory.id,
                    name: updatedCategory.name,
                    description: updatedCategory.description || undefined,
                    createdAt: updatedCategory.created_at ? new Date(updatedCategory.created_at) : new Date()
                };
            }
            catch (error) {
                console.error('Update category error:', error);
                throw error;
            }
        });
    }
    static deleteCategory(categoryId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield prisma.blog_categories.delete({
                    where: {
                        id: categoryId
                    }
                });
            }
            catch (error) {
                console.error('Delete category error:', error);
                throw error;
            }
        });
    }
    static getCategoryById(categoryId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const category = yield prisma.blog_categories.findUnique({
                    where: {
                        id: categoryId
                    }
                });
                if (!category)
                    return null;
                return {
                    id: category.id,
                    name: category.name,
                    description: category.description || undefined,
                    createdAt: category.created_at ? new Date(category.created_at) : new Date()
                };
            }
            catch (error) {
                console.error('Get category by ID error:', error);
                throw error;
            }
        });
    }
}
exports.BlogCategoryService = BlogCategoryService;
