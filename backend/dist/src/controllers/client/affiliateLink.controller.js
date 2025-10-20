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
exports.ClientAffiliateLinkController = void 0;
const prisma_1 = __importDefault(require("../../config/prisma"));
class ClientAffiliateLinkController {
    // Voir à quel affilié le client est lié (actuellement)
    static getCurrentAffiliate(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const now = new Date();
                const link = yield prisma_1.default.affiliate_client_links.findFirst({
                    where: {
                        client_id: userId,
                        start_date: { lte: now },
                        OR: [
                            { end_date: null },
                            { end_date: { gte: now } }
                        ],
                        affiliate: {
                            is_active: true,
                            status: 'ACTIVE'
                        }
                    },
                    include: {
                        affiliate: {
                            select: {
                                id: true,
                                affiliate_code: true,
                                users: { select: { first_name: true, last_name: true, email: true } }
                            }
                        }
                    },
                    orderBy: { start_date: 'desc' }
                });
                if (!link)
                    return res.json({ data: null });
                res.json({ data: link.affiliate });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
}
exports.ClientAffiliateLinkController = ClientAffiliateLinkController;
