import { Request, Response } from 'express';
import { OrderService } from '../services/order.service';
import { validateOrder } from '../middleware/validators';
import PDFDocument from 'pdfkit'; // Ajouter cette dépendance

export class OrderController {
  static async createOrder(req: Request, res: Response) {
    try {
      const { 
        serviceId, 
        addressId, 
        quantity, 
        isRecurring, 
        recurrenceType, 
        collectionDate, 
        deliveryDate, 
        gpsLatitude, 
        gpsLongitude, 
        affiliateCode,
        items  // Add this line
      } = req.body;
      
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const orderData = {
        userId,
        serviceId,
        addressId,
        quantity,
        isRecurring,
        recurrenceType,
        collectionDate,
        deliveryDate,
        gpsLatitude,
        gpsLongitude,
        affiliateCode,
        items: items || []  // Add this line with default empty array
      };

      const result = await OrderService.createOrder(orderData);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
  static async getUserOrders(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      console.log('Getting orders for user ID:', userId);

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const orders = await OrderService.getUserOrders(userId);
      console.log('Found orders:', orders.length);
      
      res.json({ 
        data: orders,
        meta: {
          total: orders.length,
          hasOrders: orders.length > 0
        }
      });
    } catch (error: any) {
      console.error('Error getting user orders:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async getOrderDetails(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      const orderId = req.params.orderId;
      
      console.log('Getting order details:', { userId, orderId });

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const order = await OrderService.getOrderDetails(orderId, userId);
      console.log('Found order:', order);
      
      res.json({ data: order });
    } catch (error: any) {
      console.error('Order details error:', error);
      res.status(error.message === 'Order not found' ? 404 : 500)
         .json({ error: error.message });
    }
  }

  static async updateOrderStatus(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const orderId = req.params.orderId;
      const { status } = req.body;
      const result = await OrderService.updateOrderStatus(orderId, status, userId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getAllOrders(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await OrderService.getAllOrders(userId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
  static async deleteOrder(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const orderId = req.params.orderId;
      const result = await OrderService.deleteOrder(orderId, userId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async generateInvoice(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      const orderId = req.params.orderId;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      // Récupérer les détails de la commande
      const order = await OrderService.getOrderDetails(orderId, userId);

      // Vérifier si la commande est prête
      if (order.status !== 'READY' && order.status !== 'DELIVERED') {
        return res.status(400).json({ 
          error: 'Invoice can only be generated for READY or DELIVERED orders' 
        });
      }

      // Générer le PDF
      const doc = new PDFDocument();
      res.setHeader('Content-Type', 'application/pdf');
      res.setHeader('Content-Disposition', `attachment; filename=invoice-${orderId}.pdf`);
      doc.pipe(res);

      // En-tête de la facture
      doc.fontSize(20).text('Alpha Laundry Invoice', { align: 'center' });
      doc.moveDown();
      doc.fontSize(12).text(`Order ID: ${order.id}`);
      doc.text(`Date: ${new Date().toLocaleDateString()}`);
      doc.moveDown();

      // Détails du service
      doc.text(`Service: ${order.service?.name}`);
      doc.text(`Amount: $${order.totalAmount}`);
      
      // Finaliser le PDF
      doc.end();

    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}
