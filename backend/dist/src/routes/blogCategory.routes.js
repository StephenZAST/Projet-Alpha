"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const blogCategory_controller_1 = require("../controllers/blogCategory.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const asyncHandler_1 = require("../utils/asyncHandler");
const router = express_1.default.Router();
router.use(auth_middleware_1.authenticateToken);
// Routes publiques (clients)
router.get('/', (0, asyncHandler_1.asyncHandler)((req, res, next) => blogCategory_controller_1.BlogCategoryController.getAllCategories(req, res)));
// Routes admin
router.use((0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']));
router.post('/', (0, asyncHandler_1.asyncHandler)((req, res, next) => blogCategory_controller_1.BlogCategoryController.createCategory(req, res)));
router.put('/:categoryId', (0, asyncHandler_1.asyncHandler)((req, res, next) => blogCategory_controller_1.BlogCategoryController.updateCategory(req, res)));
router.delete('/:categoryId', (0, asyncHandler_1.asyncHandler)((req, res, next) => blogCategory_controller_1.BlogCategoryController.deleteCategory(req, res)));
exports.default = router;
