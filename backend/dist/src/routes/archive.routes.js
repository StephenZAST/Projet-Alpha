"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const archive_controller_1 = require("../controllers/archive.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const router = express_1.default.Router();
// Route accessible à tous les utilisateurs authentifiés
router.get('/orders', auth_middleware_1.authenticateToken, archive_controller_1.ArchiveController.getArchivedOrders);
// Route pour archiver une commande (admin ou propriétaire)
router.post('/orders/:orderId', auth_middleware_1.authenticateToken, archive_controller_1.ArchiveController.archiveOrder);
// Route accessible uniquement aux ADMIN et SUPER_ADMIN
router.post('/cleanup', auth_middleware_1.authenticateToken, (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), // Ajout de SUPER_ADMIN
archive_controller_1.ArchiveController.runArchiveCleanup);
exports.default = router;
