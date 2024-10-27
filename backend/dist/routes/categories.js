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
const categories_1 = require("../services/categories");
const router = express_1.default.Router();
router.get('/', (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const categories = yield (0, categories_1.getCategories)();
        res.json(categories);
    }
    catch (error) {
        next(error);
    }
}));
router.post('/', auth_1.authenticateUser, auth_1.requireAdmin, (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const category = yield (0, categories_1.createCategory)(req.body);
        res.status(201).json(category);
    }
    catch (error) {
        next(error);
    }
}));
router.put('/:id', auth_1.authenticateUser, auth_1.requireAdmin, (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const categoryId = req.params.id;
        const updatedCategory = yield (0, categories_1.updateCategory)(categoryId, req.body);
        if (!updatedCategory) {
            return res.status(404).json({ error: 'Category not found' });
        }
        res.json(updatedCategory);
    }
    catch (error) {
        next(error);
    }
}));
router.delete('/:id', auth_1.authenticateUser, auth_1.requireAdmin, (req, res, next) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        const categoryId = req.params.id;
        yield (0, categories_1.deleteCategory)(categoryId);
        res.status(204).send();
    }
    catch (error) {
        next(error);
    }
}));
exports.default = router;
