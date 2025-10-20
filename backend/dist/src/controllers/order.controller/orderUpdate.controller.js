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
exports.OrderUpdateController = void 0;
const orderUpdate_service_1 = require("../../services/order.service/orderUpdate.service");
class OrderUpdateController {
    /**
     * PATCH /orders/:orderId
     * Permet de mettre à jour un ou plusieurs champs d'une commande (paiement, dates, code affilié, etc.)
     */
    static patchOrderFields(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            const { orderId } = req.params;
            const userId = (_a = req.user) === null || _a === void 0 ? void 0 : _a.id;
            const userRole = (_b = req.user) === null || _b === void 0 ? void 0 : _b.role;
            if (!userId || !userRole) {
                console.warn(`[OrderUpdateController] Unauthorized PATCH attempt on order ${orderId}`);
                return res.status(401).json({ success: false, error: 'Unauthorized' });
            }
            const updateFields = req.body;
            console.log(`[OrderUpdateController] PATCH /orders/${orderId} by user ${userId} (${userRole})`, updateFields);
            try {
                const updatedOrder = yield orderUpdate_service_1.OrderUpdateService.patchOrderFields(orderId, updateFields, userId, userRole);
                console.log(`[OrderUpdateController] PATCH success for order ${orderId}`);
                return res.json({ success: true, data: updatedOrder });
            }
            catch (error) {
                console.error(`[OrderUpdateController] Error patching order ${orderId}:`, error);
                // Ajout d'un log plus détaillé pour les erreurs Prisma ou validation
                if (error.code) {
                    console.error(`[OrderUpdateController] Prisma/DB error code: ${error.code}`);
                }
                return res.status(500).json({ success: false, error: error.message });
            }
        });
    }
}
exports.OrderUpdateController = OrderUpdateController;
