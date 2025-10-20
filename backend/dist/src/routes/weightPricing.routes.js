"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const weightPricing_controller_1 = require("../controllers/weightPricing.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const asyncHandler_1 = require("../utils/asyncHandler");
const router = express_1.default.Router();
// Routes protégées nécessitant une authentification
router.use(auth_middleware_1.authenticateToken);
// Routes publiques avec protection admin
router.get('/', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(weightPricing_controller_1.WeightPricingController.getAll));
router.post('/', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(weightPricing_controller_1.WeightPricingController.create));
// Routes de calcul de prix
router.get('/calculate', (0, asyncHandler_1.asyncHandler)(weightPricing_controller_1.WeightPricingController.calculatePrice));
router.patch('/:id', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(weightPricing_controller_1.WeightPricingController.update));
router.delete('/:id', (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)(weightPricing_controller_1.WeightPricingController.delete));
exports.default = router;
