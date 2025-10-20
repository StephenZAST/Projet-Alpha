"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const pricing_controller_1 = require("../controllers/pricing.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const asyncHandler_1 = require("../utils/asyncHandler");
const router = express_1.default.Router();
router.use(auth_middleware_1.authenticateToken);
router.post('/calculate', (0, asyncHandler_1.asyncHandler)(pricing_controller_1.PricingController.calculatePrice));
exports.default = router;
