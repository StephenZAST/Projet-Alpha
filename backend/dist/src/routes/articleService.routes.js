"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const articleService_controller_1 = require("../controllers/articleService.controller");
const articleServicePrice_controller_1 = require("../controllers/articleServicePrice.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const asyncHandler_1 = require("../utils/asyncHandler");
const router = express_1.default.Router();
// Routes publiques (pas d'authentification requise pour la lecture)
router.get('/prices', (0, asyncHandler_1.asyncHandler)(articleService_controller_1.ArticleServiceController.getAllPrices));
router.get('/:articleId/prices', (0, asyncHandler_1.asyncHandler)(articleService_controller_1.ArticleServiceController.getArticlePrices));
router.get('/couples', (0, asyncHandler_1.asyncHandler)(articleService_controller_1.ArticleServiceController.getCouplesForServiceType));
// Routes protégées (nécessitent authentification + rôle ADMIN)
router.post('/prices', auth_middleware_1.authenticateToken, (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(articleService_controller_1.ArticleServiceController.createPrice));
router.put('/prices/:id', auth_middleware_1.authenticateToken, (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(articleService_controller_1.ArticleServiceController.updatePrice));
router.delete('/prices/:id', auth_middleware_1.authenticateToken, (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(articleServicePrice_controller_1.ArticleServicePriceController.delete));
exports.default = router;
