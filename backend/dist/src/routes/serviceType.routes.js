"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const serviceType_controller_1 = require("../controllers/serviceType.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const asyncHandler_1 = require("../utils/asyncHandler");
const router = express_1.default.Router();
// Routes publiques (pas d'authentification requise pour la lecture)
router.get('/', (0, asyncHandler_1.asyncHandler)((req, res) => serviceType_controller_1.ServiceTypeController.getAllServiceTypes(req, res)));
router.get('/:id', (0, asyncHandler_1.asyncHandler)((req, res) => serviceType_controller_1.ServiceTypeController.getServiceType(req, res)));
// Routes admin (nécessitent authentification + rôle ADMIN)
router.post('/', auth_middleware_1.authenticateToken, (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => serviceType_controller_1.ServiceTypeController.createServiceType(req, res)));
router.put('/:id', auth_middleware_1.authenticateToken, (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => serviceType_controller_1.ServiceTypeController.updateServiceType(req, res)));
router.delete('/:id', auth_middleware_1.authenticateToken, (0, auth_middleware_1.authorizeRoles)(['ADMIN', 'SUPER_ADMIN']), (0, asyncHandler_1.asyncHandler)((req, res) => serviceType_controller_1.ServiceTypeController.deleteServiceType(req, res)));
exports.default = router;
