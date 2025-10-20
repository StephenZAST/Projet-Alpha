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
exports.priceUpdateEmitter = void 0;
const events_1 = require("events");
const articlePriceCache_service_1 = require("../services/articlePriceCache.service");
const notification_service_1 = require("../services/notification.service");
const types_1 = require("../models/types");
const prisma_1 = __importDefault(require("../config/prisma"));
const client_1 = require("@prisma/client");
exports.priceUpdateEmitter = new events_1.EventEmitter();
exports.priceUpdateEmitter.on('price.updated', (data) => __awaiter(void 0, void 0, void 0, function* () {
    try {
        // 1. Invalider le cache
        yield articlePriceCache_service_1.ArticlePriceCacheService.invalidatePrice(data.articleId, data.serviceTypeId);
        // 2. Récupérer les administrateurs
        const admins = yield prisma_1.default.users.findMany({
            where: {
                role: {
                    in: [client_1.user_role.ADMIN, client_1.user_role.SUPER_ADMIN]
                }
            },
            select: {
                id: true
            }
        });
        const notificationType = types_1.NotificationType.PRICE_UPDATED;
        // 3. Notifier chaque administrateur
        const notificationPromises = admins.map((admin) => notification_service_1.NotificationService.sendNotification(admin.id, notificationType, {
            title: 'Mise à jour des prix',
            message: `Prix mis à jour pour l'article ${data.articleId}`,
            data: {
                articleId: data.articleId,
                oldPrice: data.oldPrice,
                newPrice: data.newPrice,
                modifiedBy: data.userId
            }
        }));
        yield Promise.all(notificationPromises);
        // 4. Logger l'événement
        console.log('[PriceUpdateEvent] Price updated successfully:', {
            articleId: data.articleId,
            modifiedBy: data.userId,
            adminsNotified: admins.length
        });
    }
    catch (error) {
        console.error('[PriceUpdateEvent] Error handling price update:', error);
    }
}));
