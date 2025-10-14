import { Request, Response } from 'express';
import { ClientOrderQueryService } from '../../services/order.service/clientOrderQuery.service';

/**
 * 📱 Contrôleur de commandes pour le CLIENT APP
 * 
 * Endpoints dédiés à l'application client mobile avec données enrichies
 */
export class ClientOrderController {
  
  /**
   * GET /api/orders/client/my-orders
   * Récupère les commandes de l'utilisateur connecté avec enrichissement
   */
  static async getMyOrdersEnriched(req: Request, res: Response) {
    try {
      const userId = (req as any).user?.id;
      
      console.log('[ClientOrderController] 📱 getMyOrdersEnriched called for userId:', userId);
      
      if (!userId) {
        console.log('[ClientOrderController] ❌ No userId found');
        return res.status(401).json({
          success: false,
          error: 'Non authentifié'
        });
      }

      const orders = await ClientOrderQueryService.getUserOrdersEnriched(userId);
      
      console.log('[ClientOrderController] ✅ Orders fetched:', orders.length);
      console.log('[ClientOrderController] 📊 First order sample:', JSON.stringify({
        id: orders[0]?.id,
        itemsCount: orders[0]?.itemsCount,
        itemsLength: orders[0]?.items?.length
      }, null, 2));

      res.json({
        success: true,
        data: orders
      });
    } catch (error: any) {
      console.error('[ClientOrderController] ❌ Error in getMyOrdersEnriched:', error);
      res.status(500).json({
        success: false,
        error: 'Erreur serveur',
        message: error.message
      });
    }
  }

  /**
   * GET /api/orders/client/by-id/:orderId
   * Récupère une commande par ID avec enrichissement
   */
  static async getOrderByIdEnriched(req: Request, res: Response) {
    try {
      const { orderId } = req.params;
      const userId = (req as any).user?.id;

      if (!userId) {
        return res.status(401).json({
          success: false,
          error: 'Non authentifié'
        });
      }

      const order = await ClientOrderQueryService.getOrderByIdEnriched(orderId);

      // Vérifier que la commande appartient à l'utilisateur
      if (order.userId !== userId) {
        return res.status(403).json({
          success: false,
          error: 'Accès non autorisé'
        });
      }

      res.json({
        success: true,
        data: order
      });
    } catch (error: any) {
      console.error('[ClientOrderController] Error in getOrderByIdEnriched:', error);
      
      if (error.message === 'Order not found') {
        return res.status(404).json({
          success: false,
          error: 'Commande non trouvée'
        });
      }

      res.status(500).json({
        success: false,
        error: 'Erreur serveur',
        message: error.message
      });
    }
  }

  /**
   * GET /api/orders/client/recent
   * Récupère les commandes récentes avec enrichissement
   */
  static async getRecentOrdersEnriched(req: Request, res: Response) {
    try {
      const userId = (req as any).user?.id;
      const limit = parseInt(req.query.limit as string) || 5;

      if (!userId) {
        return res.status(401).json({
          success: false,
          error: 'Non authentifié'
        });
      }

      const orders = await ClientOrderQueryService.getRecentOrdersEnriched(userId, limit);

      res.json({
        success: true,
        data: orders
      });
    } catch (error: any) {
      console.error('[ClientOrderController] Error in getRecentOrdersEnriched:', error);
      res.status(500).json({
        success: false,
        error: 'Erreur serveur',
        message: error.message
      });
    }
  }
}
