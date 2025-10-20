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
Object.defineProperty(exports, "__esModule", { value: true });
exports.ArticleServicePriceController = void 0;
const articleServicePrice_service_1 = require("../services/articleServicePrice.service");
class ArticleServicePriceController {
    static create(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { article_id, service_type_id, service_id, base_price, premium_price, price_per_kg, is_available } = req.body;
                if (!article_id || !service_type_id || !base_price) {
                    return res.status(400).json({
                        success: false,
                        error: 'Missing required fields'
                    });
                }
                const newPrice = yield articleServicePrice_service_1.ArticleServicePriceService.create({
                    article_id,
                    service_type_id,
                    service_id: service_id !== null && service_id !== void 0 ? service_id : undefined,
                    base_price,
                    premium_price,
                    price_per_kg,
                    is_available: is_available !== null && is_available !== void 0 ? is_available : true
                });
                res.status(201).json({
                    success: true,
                    data: newPrice
                });
            }
            catch (error) {
                res.status(error.code === 'P2002' ? 409 : 400).json({
                    success: false,
                    error: error.message
                });
            }
        });
    }
    static update(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const { id } = req.params;
                const priceData = req.body;
                const updateDTO = Object.assign(Object.assign({}, priceData), { service_id: (_a = priceData.service_id) !== null && _a !== void 0 ? _a : undefined });
                const updatedPrice = yield articleServicePrice_service_1.ArticleServicePriceService.update(id, updateDTO);
                res.json({
                    success: true,
                    data: updatedPrice
                });
            }
            catch (error) {
                res.status(400).json({
                    success: false,
                    error: error.message
                });
            }
        });
    }
    static getByArticleId(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { articleId } = req.params;
                const prices = yield articleServicePrice_service_1.ArticleServicePriceService.getByArticleId(articleId);
                res.json({
                    success: true,
                    data: prices
                });
            }
            catch (error) {
                res.status(400).json({
                    success: false,
                    error: error.message
                });
            }
        });
    }
    static delete(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { id } = req.params;
                yield articleServicePrice_service_1.ArticleServicePriceService.delete(id);
                res.json({
                    success: true,
                    message: "Prix de service supprimé avec succès"
                });
            }
            catch (error) {
                res.status(400).json({
                    success: false,
                    error: error.message
                });
            }
        });
    }
}
exports.ArticleServicePriceController = ArticleServicePriceController;
