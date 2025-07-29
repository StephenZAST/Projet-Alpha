import { Request, Response } from 'express';
import { OrderUpdateService } from '../../services/order.service/orderUpdate.service';

export class OrderUpdateController {
  /**
   * PATCH /orders/:orderId
   * Permet de mettre à jour un ou plusieurs champs d'une commande (paiement, dates, code affilié, etc.)
   */
  static async patchOrderFields(req: Request, res: Response) {
    const { orderId } = req.params;
    const userId = req.user?.id;
    const userRole = req.user?.role;
    if (!userId || !userRole) {
      console.warn(`[OrderUpdateController] Unauthorized PATCH attempt on order ${orderId}`);
      return res.status(401).json({ success: false, error: 'Unauthorized' });
    }
    const updateFields = req.body;
    console.log(`[OrderUpdateController] PATCH /orders/${orderId} by user ${userId} (${userRole})`, updateFields);
    try {
      const updatedOrder = await OrderUpdateService.patchOrderFields(orderId, updateFields, userId, userRole);
      console.log(`[OrderUpdateController] PATCH success for order ${orderId}`);
      return res.json({ success: true, data: updatedOrder });
    } catch (error: any) {
      console.error(`[OrderUpdateController] Error patching order ${orderId}:`, error);
      // Ajout d'un log plus détaillé pour les erreurs Prisma ou validation
      if (error.code) {
        console.error(`[OrderUpdateController] Prisma/DB error code: ${error.code}`);
      }
      return res.status(500).json({ success: false, error: error.message });
    }
  }
}
