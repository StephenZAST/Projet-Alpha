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
exports.ArticleServiceController = void 0;
// import legacy service supprimé
const articleServicePrice_service_1 = require("../services/articleServicePrice.service");
const errorHandler_1 = require("../utils/errorHandler");
class ArticleServiceController {
    // Retourne tous les couples article/serviceType disponibles avec prix
    static getCouplesForServiceType(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { serviceTypeId, serviceId } = req.query;
                if (!serviceTypeId) {
                    res.status(400).json({ success: false, message: 'serviceTypeId requis' });
                    return;
                }
                // Filtre par serviceTypeId et optionnellement serviceId
                const where = { service_type_id: serviceTypeId, is_available: true };
                if (serviceId)
                    where.service_id = serviceId;
                const couples = yield articleServicePrice_service_1.ArticleServicePriceService.getCouples(where);
                res.json({ success: true, data: couples });
            }
            catch (error) {
                (0, errorHandler_1.handleError)(res, error);
            }
        });
    }
    // Méthodes legacy supprimées : toute la logique doit passer par ArticleServicePriceService
    static getAllPrices(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const prices = yield articleServicePrice_service_1.ArticleServicePriceService.getAllPrices();
                res.json({
                    success: true,
                    data: prices
                });
            }
            catch (error) {
                (0, errorHandler_1.handleError)(res, error);
            }
        });
    }
    static getArticlePrices(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { articleId } = req.params;
                const { serviceTypeId } = req.query;
                const prices = yield articleServicePrice_service_1.ArticleServicePriceService.getArticlePrices(articleId);
                if (serviceTypeId) {
                    // On cherche le couple exact
                    const found = prices.find((p) => p.service_type_id === serviceTypeId);
                    if (found) {
                        res.json({ success: true, data: found });
                    }
                    else {
                        res.status(404).json({ success: false, message: 'No price found for this article/serviceType' });
                    }
                }
                else {
                    res.json({ success: true, data: prices });
                }
            }
            catch (error) {
                (0, errorHandler_1.handleError)(res, error);
            }
        });
    }
    static createPrice(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const priceData = {
                    article_id: req.body.article_id,
                    service_type_id: req.body.service_type_id,
                    base_price: req.body.base_price,
                    premium_price: req.body.premium_price,
                    price_per_kg: req.body.price_per_kg,
                    is_available: true
                };
                const newPrice = yield articleServicePrice_service_1.ArticleServicePriceService.create(priceData);
                res.status(201).json({
                    success: true,
                    data: newPrice
                });
            }
            catch (error) {
                (0, errorHandler_1.handleError)(res, error);
            }
        });
    }
    static updatePrice(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const { id } = req.params;
                const priceData = req.body;
                const updateDTO = {
                    base_price: priceData.basePrice,
                    premium_price: priceData.premiumPrice,
                    price_per_kg: priceData.pricePerKg,
                    is_available: priceData.isAvailable
                };
                const updatedPrice = yield articleServicePrice_service_1.ArticleServicePriceService.update(id, updateDTO);
                res.json({
                    success: true,
                    data: updatedPrice
                });
            }
            catch (error) {
                (0, errorHandler_1.handleError)(res, error);
            }
        });
    }
}
exports.ArticleServiceController = ArticleServiceController;
