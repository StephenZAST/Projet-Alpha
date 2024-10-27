"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const auth_1 = require("../middleware/auth");
const router = express_1.default.Router();
// Protected route requiring authentication
router.get('/profile', auth_1.authenticateUser, (req, res) => {
    res.json({ user: req.user });
});
// Protected route requiring admin privileges
router.get('/all', auth_1.authenticateUser, auth_1.requireAdmin, (req, res) => {
    // Only admins can access this route
});
exports.default = router;
