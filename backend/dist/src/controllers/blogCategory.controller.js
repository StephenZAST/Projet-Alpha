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
exports.BlogCategoryController = void 0;
const blogCategory_service_1 = require("../services/blogCategory.service");
class BlogCategoryController {
    static createCategory(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { name, description } = req.body;
                const category = yield blogCategory_service_1.BlogCategoryService.createCategory(name, description);
                res.json({ data: category });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getAllCategories(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const categories = yield blogCategory_service_1.BlogCategoryService.getAllCategories();
                res.json({ data: categories });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static updateCategory(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { categoryId } = req.params;
                const { name, description } = req.body;
                const category = yield blogCategory_service_1.BlogCategoryService.updateCategory(categoryId, name, description);
                res.json({ data: category });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static deleteCategory(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { categoryId } = req.params;
                yield blogCategory_service_1.BlogCategoryService.deleteCategory(categoryId);
                res.json({ success: true });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
}
exports.BlogCategoryController = BlogCategoryController;
