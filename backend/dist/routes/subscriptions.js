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
const subscriptions_1 = require("../services/subscriptions");
const router = express_1.default.Router();
// Public routes
router.get('/', (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const subscriptions = yield (0, subscriptions_1.getSubscriptions)();
        res.json(subscriptions);
    }
    catch (error) {
        next(error);
    }
}));
// User routes
router.get('/user/:userId', auth_1.authenticateUser, (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const subscription = yield (0, subscriptions_1.getUserSubscription)(req.params.userId);
        res.json(subscription);
    }
    catch (error) {
        next(error);
    }
}));
// Admin routes
router.post('/', auth_1.authenticateUser, auth_1.requireAdmin, (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const subscription = yield (0, subscriptions_1.createSubscription)(req.body);
        res.status(201).json(subscription);
    }
    catch (error) {
        next(error);
    }
}));
router.put('/:id', auth_1.authenticateUser, auth_1.requireAdmin, (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const subscriptionId = req.params.id;
        const updatedSubscription = yield (0, subscriptions_1.updateSubscription)(subscriptionId, req.body);
        if (!updatedSubscription) {
            return res.status(404).json({ error: 'Subscription not found' });
        }
        res.json(updatedSubscription);
    }
    catch (error) {
        next(error);
    }
}));
router.delete('/:id', auth_1.authenticateUser, auth_1.requireAdmin, (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const subscriptionId = req.params.id;
        yield (0, subscriptions_1.deleteSubscription)(subscriptionId);
        res.status(204).send();
    }
    catch (error) {
        next(error);
    }
}));
exports.default = router;
