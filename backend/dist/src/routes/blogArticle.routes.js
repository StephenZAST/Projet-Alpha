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
const blogArticle_controller_1 = require("../controllers/blogArticle.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const asyncHandler_1 = require("../utils/asyncHandler");
const router = express_1.default.Router();
// Protection des routes avec authentification
router.use(auth_middleware_1.authenticateToken);
// Routes publiques (clients)
router.get('/', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () { return blogArticle_controller_1.BlogArticleController.getAllArticles(req, res); })));
// Routes admin
router.use((0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']));
router.post('/', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () { return blogArticle_controller_1.BlogArticleController.createArticle(req, res); })));
router.put('/:articleId', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () { return blogArticle_controller_1.BlogArticleController.updateArticle(req, res); })));
router.delete('/:articleId', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () { return blogArticle_controller_1.BlogArticleController.deleteArticle(req, res); })));
router.post('/generate', (0, asyncHandler_1.asyncHandler)((req, res) => __awaiter(void 0, void 0, void 0, function* () { return blogArticle_controller_1.BlogArticleController.generateArticle(req, res); })));
exports.default = router;
