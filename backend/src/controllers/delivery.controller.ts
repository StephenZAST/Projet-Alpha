import { Request, Response } from 'express';
import { DeliveryService } from '../services/delivery.service';
import { asyncHandler } from '../utils/asyncHandler'; 

export class DeliveryController {
  static async getPendingOrders(req: Request, res: Response) {
    try {
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await DeliveryService.getPendingOrders(userId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  } 

  static async getAssignedOrders(req: Request, res: Response) {
    try {
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await DeliveryService.getAssignedOrders(userId);
      
      // 🔍 DEBUG: Log les coordonnées GPS
      console.log('🗺️ [DeliveryController] Commandes assignées avec GPS:');
      result.forEach((order: any, index: number) => {
        const hasGPS = order.address?.gps_latitude && order.address?.gps_longitude;
        console.log(`   [${index + 1}] ${order.id.substring(0, 8)} - GPS: ${hasGPS ? '✅' : '❌'}`);
        if (hasGPS) {
          console.log(`       Lat: ${order.address.gps_latitude}, Lng: ${order.address.gps_longitude}`);
        } else {
          console.log(`       ⚠️ Pas de GPS pour: ${order.address?.city}, ${order.address?.street}`);
        }
      });
      
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  } 

  static async updateOrderStatus(req: Request, res: Response) {
    try {
      console.log('Request user:', req.user); // Add this line to log the user object
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const orderId = req.params.orderId;
      const { status } = req.body;
      const result = await DeliveryService.updateOrderStatus(orderId, status, userId);
      res.json({ data: result });
    } catch (error: any) {
      console.error('Error updating order status:', error); // Add this line to log the error
      res.status(500).json({ error: error.message });
    }
  }

  static async getCOLLECTEDOrders(req: Request, res: Response) {
    try {
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await DeliveryService.getCOLLECTEDOrders(userId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getPROCESSINGOrders(req: Request, res: Response) {
    try {
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await DeliveryService.getPROCESSINGOrders(userId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getREADYOrders(req: Request, res: Response) {
    try {
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await DeliveryService.getREADYOrders(userId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getDELIVERINGOrders(req: Request, res: Response) {
    try {
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await DeliveryService.getDELIVERINGOrders(userId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getDELIVEREDOrders(req: Request, res: Response) {
    try {
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await DeliveryService.getDELIVEREDOrders(userId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getCANCELLEDOrders(req: Request, res: Response) {
    try {
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await DeliveryService.getCANCELLEDOrders(userId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getDraftOrders(req: Request, res: Response) {
    try {
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      console.log('📋 [DeliveryController] Récupération des commandes DRAFT pour userId:', userId);
      
      const result = await DeliveryService.getDraftOrders(userId);
      
      console.log(`✅ [DeliveryController] ${result.length} commandes DRAFT trouvées`);
      
      res.json({ data: result });
    } catch (error: any) {
      console.error('❌ [DeliveryController] Erreur getDraftOrders:', error);
      res.status(500).json({ error: error.message });
    }
  }
}
