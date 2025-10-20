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
exports.ArticlePriceHistoryService = void 0;
const client_1 = require("@prisma/client");
const priceUpdate_events_1 = require("../events/priceUpdate.events");
const prisma = new client_1.PrismaClient();
class ArticlePriceHistoryService {
    static logPriceChange(articleId, serviceTypeId, oldPrice, newPrice, userId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const priceHistory = yield prisma.price_history.create({
                    data: {
                        id: userId, // Utilisé comme stockage temporaire car requis par le schéma
                        valid_from: new Date(),
                        valid_to: null
                    }
                });
                // Émettre l'événement de mise à jour
                priceUpdate_events_1.priceUpdateEmitter.emit('price.updated', {
                    articleId,
                    serviceTypeId,
                    oldPrice,
                    newPrice,
                    userId
                });
                return {
                    id: priceHistory.id,
                    article_id: articleId,
                    service_type_id: serviceTypeId,
                    old_price: oldPrice,
                    new_price: newPrice,
                    modified_by: userId,
                    created_at: new Date(),
                    modifier: yield this.getModifierInfo(userId)
                };
            }
            catch (error) {
                console.error('[ArticlePriceHistoryService] Error logging price change:', error);
                throw error;
            }
        });
    }
    static getPriceHistory(articleId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const history = yield prisma.price_history.findMany({
                    orderBy: {
                        valid_from: 'desc'
                    }
                });
                const entries = [];
                for (const entry of history) {
                    const modifier = yield this.getModifierInfo(entry.id);
                    entries.push({
                        id: entry.id,
                        article_id: articleId,
                        service_type_id: '', // Not available in current schema
                        old_price: {}, // Not available in current schema
                        new_price: {}, // Not available in current schema
                        modified_by: entry.id,
                        created_at: entry.valid_from,
                        modifier
                    });
                }
                return entries;
            }
            catch (error) {
                console.error('[ArticlePriceHistoryService] Error getting price history:', error);
                throw error;
            }
        });
    }
    static getModifierInfo(userId) {
        return __awaiter(this, void 0, void 0, function* () {
            const user = yield prisma.users.findUnique({
                where: { id: userId },
                select: {
                    id: true,
                    email: true,
                    first_name: true,
                    last_name: true
                }
            });
            return user ? {
                id: user.id,
                email: user.email,
                firstName: user.first_name,
                lastName: user.last_name
            } : undefined;
        });
    }
}
exports.ArticlePriceHistoryService = ArticlePriceHistoryService;
