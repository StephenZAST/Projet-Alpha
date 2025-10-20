"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const articleCategory_controller_1 = require("../controllers/articleCategory.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const asyncHandler_1 = require("../utils/asyncHandler");
const router = express_1.default.Router();
// Routes publiques (pas d'authentification requise pour la lecture)
router.get('/', (0, asyncHandler_1.asyncHandler)(articleCategory_controller_1.ArticleCategoryController.getAllArticleCategories));
router.get('/:categoryId', (0, asyncHandler_1.asyncHandler)(articleCategory_controller_1.ArticleCategoryController.getArticleCategoryById));
// Routes protégées (nécessitent authentification + rôle ADMIN)
router.post('/', auth_middleware_1.authenticateToken, (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(articleCategory_controller_1.ArticleCategoryController.createArticleCategory));
router.patch('/:categoryId', auth_middleware_1.authenticateToken, (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(articleCategory_controller_1.ArticleCategoryController.updateArticleCategory));
router.delete('/:categoryId', auth_middleware_1.authenticateToken, (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(articleCategory_controller_1.ArticleCategoryController.deleteArticleCategory));
exports.default = router;
