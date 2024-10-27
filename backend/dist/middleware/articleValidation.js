"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateArticle = void 0;
const joi_1 = __importDefault(require("joi"));
const order_1 = require("../models/order");
const article_1 = require("../models/article");
const errors_1 = require("../utils/errors");
const articleSchema = joi_1.default.object({
    articleName: joi_1.default.string().required(),
    articleCategory: joi_1.default.string().valid(...Object.values(article_1.ArticleCategory)).required(),
    prices: joi_1.default.object().pattern(joi_1.default.string().valid(...Object.values(order_1.MainService)), joi_1.default.object().pattern(joi_1.default.string().valid(...Object.values(order_1.PriceType)), joi_1.default.number().min(0))).required(),
    availableServices: joi_1.default.array().items(joi_1.default.string().valid(...Object.values(order_1.MainService))).required(),
    availableAdditionalServices: joi_1.default.array().items(joi_1.default.string()).required()
});
const validateArticle = (req, res, next) => {
    const { error } = articleSchema.validate(req.body);
    if (error) {
        const errorMessage = error.details[0].message;
        throw new errors_1.AppError(400, errorMessage, errors_1.errorCodes.INVALID_ARTICLE_DATA);
    }
    next();
};
exports.validateArticle = validateArticle;
