"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateOrder = void 0;
// src/middleware/validation.ts
const joi_1 = __importDefault(require("joi"));
const validateOrder = (req, res, next) => {
    const schema = joi_1.default.object({
        userId: joi_1.default.string().required(),
        serviceType: joi_1.default.string().required(),
        items: joi_1.default.array().min(1).required(),
        // Add more validation rules
    });
    const { error } = schema.validate(req.body);
    if (error) {
        return res.status(400).json({ error: error.details[0].message });
    }
    next();
};
exports.validateOrder = validateOrder;
