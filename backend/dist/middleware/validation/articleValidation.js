"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.priceRangeValidation = exports.categoryValidationSchema = exports.articleValidationSchema = void 0;
const joi_1 = __importDefault(require("joi"));
const order_1 = require("../../models/order");
const article_1 = require("../../models/article");
exports.articleValidationSchema = joi_1.default.object({
    articleName: joi_1.default.string().required().min(2).max(100),
    articleCategory: joi_1.default.string()
        .valid(...Object.values(article_1.ArticleCategory))
        .required(),
    prices: joi_1.default.object()
        .pattern(joi_1.default.string().valid(...Object.values(order_1.MainService)), joi_1.default.object().pattern(joi_1.default.string().valid(...Object.values(order_1.PriceType)), joi_1.default.number().min(0).max(100000)))
        .required(),
    availableServices: joi_1.default.array()
        .items(joi_1.default.string().valid(...Object.values(order_1.MainService)))
        .min(1)
        .required(),
    availableAdditionalServices: joi_1.default.array()
        .items(joi_1.default.string())
        .default([])
});
exports.categoryValidationSchema = joi_1.default.object({
    name: joi_1.default.string().required().min(2).max(50),
    description: joi_1.default.string().max(200),
    isActive: joi_1.default.boolean().default(true)
});
const priceRangeValidation = (price, service) => {
    const maxPrices = {
        [order_1.MainService.PRESSING]: 50000,
        [order_1.MainService.DRY_CLEANING]: 75000,
        [order_1.MainService.IRONING]: 25000,
        [order_1.MainService.WASH_AND_IRON]: 75000,
        [order_1.MainService.WASH_ONLY]: 50000,
        [order_1.MainService.IRON_ONLY]: 25000,
        [order_1.MainService.PICKUP_DELIVERY]: 0
    };
    return price >= 0 && price <= maxPrices[service];
};
exports.priceRangeValidation = priceRangeValidation;
