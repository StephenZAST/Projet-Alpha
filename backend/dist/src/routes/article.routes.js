"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const article_controller_1 = require("../controllers/article.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const asyncHandler_1 = require("../utils/asyncHandler");
const router = express_1.default.Router();
// Routes publiques
router.get('/', (0, asyncHandler_1.asyncHandler)(article_controller_1.ArticleController.getAllArticles));
router.get('/category/:categoryId', (0, asyncHandler_1.asyncHandler)(article_controller_1.ArticleController.getArticlesByCategory));
router.get('/:articleId', (0, asyncHandler_1.asyncHandler)(article_controller_1.ArticleController.getArticleById));
// Routes protégées - nécessitent authentification
router.use(auth_middleware_1.authenticateToken);
// Routes CRUD - Accessibles aux admins
router.post('/', (0, asyncHandler_1.asyncHandler)(article_controller_1.ArticleController.createArticle));
router.patch('/:articleId', (0, asyncHandler_1.asyncHandler)(article_controller_1.ArticleController.updateArticle) // Suppression de la restriction ADMIN
);
router.delete('/:articleId', (0, asyncHandler_1.asyncHandler)(article_controller_1.ArticleController.deleteArticle));
router.post('/:articleId/archive', (0, auth_middleware_1.authorizeRoles)(['ADMIN']), (0, asyncHandler_1.asyncHandler)(article_controller_1.ArticleController.archiveArticle));
exports.default = router;
