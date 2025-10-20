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
exports.ArticleCategoryController = void 0;
const articleCategory_service_1 = require("../services/articleCategory.service");
class ArticleCategoryController {
    static createArticleCategory(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const categoryData = req.body;
                const result = yield articleCategory_service_1.ArticleCategoryService.createArticleCategory(categoryData);
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getArticleCategoryById(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const categoryId = req.params.categoryId;
                const result = yield articleCategory_service_1.ArticleCategoryService.getArticleCategoryById(categoryId);
                res.json({ data: result });
            }
            catch (error) {
                res.status(error.message === 'Article category not found' ? 404 : 500)
                    .json({ error: error.message });
            }
        });
    }
    static getAllArticleCategories(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const categories = yield articleCategory_service_1.ArticleCategoryService.getAllArticleCategories();
                // articlesCount est inclus dans chaque objet catégorie
                return res.status(200).json({
                    success: true,
                    data: categories,
                    message: 'Catégories récupérées avec succès'
                });
            }
            catch (error) {
                console.error('Erreur dans getAllArticleCategories controller:', error);
                return res.status(500).json({
                    success: false,
                    message: 'Échec de la récupération des catégories',
                    error: error instanceof Error ? error.message : 'Erreur inconnue'
                });
            }
        });
    }
    static updateArticleCategory(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                console.log('[ArticleCategoryController] Update request:', {
                    id: req.params.categoryId,
                    data: req.body
                });
                const categoryId = req.params.categoryId;
                const categoryData = req.body;
                const result = yield articleCategory_service_1.ArticleCategoryService.updateArticleCategory(categoryId, categoryData);
                return res.status(200).json({
                    success: true,
                    data: result,
                    message: 'Category updated successfully'
                });
            }
            catch (error) {
                console.error('[ArticleCategoryController] Update error:', error);
                if (error instanceof Error) {
                    if (error.message.includes('not found')) {
                        return res.status(404).json({
                            success: false,
                            message: 'Category not found',
                            error: error.message
                        });
                    }
                }
                return res.status(500).json({
                    success: false,
                    message: 'Failed to update category',
                    error: error instanceof Error ? error.message : 'Unknown error'
                });
            }
        });
    }
    static deleteArticleCategory(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const categoryId = req.params.categoryId;
                yield articleCategory_service_1.ArticleCategoryService.deleteArticleCategory(categoryId);
                res.json({ message: 'Article category deleted successfully' });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
}
exports.ArticleCategoryController = ArticleCategoryController;
