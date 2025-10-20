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
exports.ArchiveController = void 0;
const archive_service_1 = require("../services/archive.service");
class ArchiveController {
    /**
     * Archive une commande à la demande (manuel)
     */
    static archiveOrder(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                const userRole = (_b = req.user) === null || _b === void 0 ? void 0 : _b.role;
                const isAdmin = userRole === 'ADMIN' || userRole === 'SUPER_ADMIN';
                const { orderId } = req.params;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                if (!orderId)
                    return res.status(400).json({ error: 'orderId requis' });
                yield archive_service_1.ArchiveService.archiveOrder(orderId, userId, isAdmin);
                res.json({ message: 'Commande archivée avec succès' });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static getArchivedOrders(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a;
            try {
                const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
                if (!userId)
                    return res.status(401).json({ error: 'Unauthorized' });
                const page = parseInt(req.query.page) || 1;
                const limit = parseInt(req.query.limit) || 10;
                const archives = yield archive_service_1.ArchiveService.getArchivedOrders(userId, page, limit);
                res.json(archives);
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
    static runArchiveCleanup(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const days = parseInt(req.query.days) || 30;
                const archivedCount = yield archive_service_1.ArchiveService.archiveOldOrders(days);
                res.json({ archived: archivedCount });
            }
            catch (error) {
                res.status(500).json({ error: error.message });
            }
        });
    }
}
exports.ArchiveController = ArchiveController;
