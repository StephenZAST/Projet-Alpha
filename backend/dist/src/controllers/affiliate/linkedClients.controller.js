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
exports.LinkedClientsController = void 0;
const prisma_1 = __importDefault(require("../../config/prisma"));
class LinkedClientsController {
    // Pour un affilié : voir la liste de ses clients liés et leurs commandes
    static getLinkedClients(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const affiliateProfile = yield prisma_1.default.affiliate_profiles.findFirst({
                    where: { userId: (_a = req.user) === null || _a === void 0 ? void 0 : _a.id },
                    select: { id: true, affiliate_code: true }
                });
                if (!affiliateProfile) {
                    return res.status(404).json({ error: 'Profil affilié non trouvé' });
                }
                const links = yield prisma_1.default.affiliate_client_links.findMany({
                    where: { affiliate_id: affiliateProfile.id },
                    include: {
                        client: { select: { id: true, first_name: true, last_name: true, email: true } }
                    },
                    orderBy: { created_at: 'desc' }
                });
                // Pour chaque client, récupérer ses commandes associées à ce code affilié
                const result = yield Promise.all(links.map((link) => __awaiter(this, void 0, void 0, function* () {
                    const affiliateCode = affiliateProfile.affiliate_code; // Récupérer le code depuis le profil
                    const orders = yield prisma_1.default.orders.findMany({
                        where: {
                            userId: link.client.id,
                            affiliateCode: affiliateCode
                        },
                        orderBy: { createdAt: 'desc' }
                    });
                    return {
                        client: link.client,
                        link: { id: link.id, start_date: link.start_date, end_date: link.end_date },
                        orders
                    };
                })));
                res.json({ data: result });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
}
exports.LinkedClientsController = LinkedClientsController;
