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
const users_1 = require("../services/users");
const validation_1 = require("../middleware/validation");
const router = express_1.default.Router();
router.post('/register', validation_1.validateUser, (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const user = req.body;
        const createdUser = yield (0, users_1.createUser)(user);
        res.status(201).json({ message: 'User created successfully', user: createdUser });
    }
    catch (error) {
        console.error('Error creating user:', error);
        res.status(500).json({ error: 'Failed to create user' });
    }
}));
router.post('/login', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const user = req.body;
        // Add your login logic here.  This is a placeholder.
        // Replace with actual Firebase authentication.
        const authenticatedUser = { userId: 'someId', username: user.username };
        res.status(200).json({ message: 'Login successful', user: authenticatedUser });
    }
    catch (error) {
        console.error('Error logging in:', error);
        res.status(401).json({ error: 'Invalid credentials' });
    }
}));
exports.default = router;
