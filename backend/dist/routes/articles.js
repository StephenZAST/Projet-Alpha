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
const express_1 = __importDefault(require("express"));
const auth_1 = require("../middleware/auth");
const articles_1 = require("../services/articles");
const router = express_1.default.Router();
// Public route - anyone can view articles
router.get('/', (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const articles = yield (0, articles_1.getArticles)();
        res.json(articles);
    }
    catch (error) {
        next(error);
    }
}));
// Protected admin routes
router.post('/', auth_1.authenticateUser, auth_1.requireAdmin, (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const article = yield (0, articles_1.createArticle)(req.body);
        res.status(201).json(article);
    }
    catch (error) {
        next(error);
    }
}));
router.put('/:id', auth_1.authenticateUser, auth_1.requireAdmin, (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const articleId = req.params.id;
        const updatedArticle = yield (0, articles_1.updateArticle)(articleId, req.body);
        if (!updatedArticle) {
            return res.status(404).json({ error: 'Article not found' });
        }
        res.json(updatedArticle);
    }
    catch (error) {
        next(error);
    }
}));
router.delete('/:id', auth_1.authenticateUser, auth_1.requireAdmin, (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const articleId = req.params.id;
        const deletedArticle = yield (0, articles_1.deleteArticle)(articleId);
        if (!deletedArticle) {
            return res.status(404).json({ error: 'Article not found' });
        }
        res.json({ message: 'Article deleted successfully' });
    }
    catch (error) {
        next(error);
    }
}));
exports.default = router;
