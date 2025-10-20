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
exports.ArticleRestrictionService = void 0;
const client_1 = require("@prisma/client");
const notification_service_1 = require("./notification.service");
const types_1 = require("../models/types");
const prisma = new client_1.PrismaClient();
class ArticleRestrictionService {
    static setRestrictions(articleId, serviceId) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // Migration : on utilise la table centralisée service_specific_prices
                const data = yield prisma.article_service_prices.upsert({
                    where: {
                        service_type_id_article_id_service_id: {
                            service_type_id: serviceId,
                            article_id: articleId,
                            service_id: ''
                        }
                    },
                    update: {
                        is_available: true,
                        updated_at: new Date()
                    },
                    create: {
                        article_id: articleId,
                        service_type_id: serviceId,
                        base_price: 0, // valeur par défaut, à ajuster si besoin
                        is_available: true,
                        created_at: new Date(),
                        updated_at: new Date()
                    },
                    include: {}
                });
                // Notifier les administrateurs des changements
                const admins = yield prisma.users.findMany({
                    where: {
                        role: {
                            in: ['ADMIN', 'SUPER_ADMIN']
                        }
                    },
                    select: {
                        id: true
                    }
                });
                yield Promise.all(admins.map(admin => notification_service_1.NotificationService.sendNotification(admin.id, types_1.NotificationType.SERVICE_UPDATED, {
                    title: 'Restrictions mises à jour',
                    message: `Les restrictions pour l'article ont été mises à jour`,
                    data: { articleId, serviceId }
                })));
                return data;
            }
            catch (error) {
                console.error('[ArticleRestrictionService] Set restrictions error:', error);
                throw error;
            }
        });
    }
}
exports.ArticleRestrictionService = ArticleRestrictionService;
