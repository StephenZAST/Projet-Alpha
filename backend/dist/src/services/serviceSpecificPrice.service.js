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
exports.ServiceSpecificPriceService = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
class ServiceSpecificPriceService {
    // Nouvelle version : utilise la table centralisée et la fonction stockée
    static getCentralizedPrice(articleId, serviceTypeId, weight) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                // Appel direct à la fonction stockée pour obtenir le prix
                const result = yield prisma.$queryRaw `SELECT public.calculate_service_price(${articleId}, ${serviceTypeId}, ${weight !== null && weight !== void 0 ? weight : null}) AS price`;
                if (Array.isArray(result) && result.length > 0 && result[0].price !== null) {
                    return Number(result[0].price);
                }
                return null;
            }
            catch (error) {
                console.error('[ServiceSpecificPriceService] Centralized price error:', error);
                throw error;
            }
        });
    }
}
exports.ServiceSpecificPriceService = ServiceSpecificPriceService;
