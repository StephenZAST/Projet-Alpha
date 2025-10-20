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
exports.BlogArticleController = void 0;
const blogArticle_service_1 = require("../services/blogArticle.service");
class BlogArticleController {
    static createArticle(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { title, content, categoryId } = req.body;
                const authorId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!authorId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const article = yield blogArticle_service_1.BlogArticleService.createArticle(title, content, categoryId, authorId);
                res.json({ data: article });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getAllArticles(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const articles = yield blogArticle_service_1.BlogArticleService.getAllArticles();
                res.json({ data: articles });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static updateArticle(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { articleId } = req.params;
                const { title, content, categoryId } = req.body;
                const article = yield blogArticle_service_1.BlogArticleService.updateArticle(articleId, title, content, categoryId);
                res.json({ data: article });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static deleteArticle(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { articleId } = req.params;
                yield blogArticle_service_1.BlogArticleService.deleteArticle(articleId);
                res.json({ success: true });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static generateArticle(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { title, context, prompts } = req.body;
                const apiKey = process.env.GOOGLE_AI_API_KEY;
                if (!apiKey)
                    return res.status(500).json({ error: 'API key not configured' });
                const content = yield blogArticle_service_1.BlogArticleService.generateArticle(title, context, prompts, apiKey);
                res.json({ data: content });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
}
exports.BlogArticleController = BlogArticleController;
