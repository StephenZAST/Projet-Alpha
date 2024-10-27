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
const analytics_1 = require("../services/analytics");
const router = express_1.default.Router();
const analyticsService = new analytics_1.AnalyticsService();
router.get('/revenue', auth_1.authenticateUser, auth_1.requireAdmin, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { startDate, endDate } = req.query;
        const metrics = yield analyticsService.getRevenueMetrics(new Date(startDate), new Date(endDate));
        res.json(metrics);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch revenue metrics' });
    }
}));
router.get('/customers', auth_1.authenticateUser, auth_1.requireAdmin, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const metrics = yield analyticsService.getCustomerMetrics();
        res.json(metrics);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch customer metrics' });
    }
}));
router.get('/affiliates', auth_1.authenticateUser, auth_1.requireAdmin, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const { startDate, endDate } = req.query;
        const metrics = yield analyticsService.getAffiliateMetrics(new Date(startDate), new Date(endDate));
        res.json(metrics);
    }
    catch (error) {
        res.status(500).json({ error: 'Failed to fetch affiliate metrics' });
    }
}));
exports.default = router;
