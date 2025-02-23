import { Request, Response } from 'express';
import supabase from '../../config/database';
import PDFDocument from 'pdfkit';
import { OrderSharedMethods, OrderItemWithArticle } from './shared'; 

export class OrderQueryController {
  static getOrderItems = OrderSharedMethods.getOrderItems;

  static async getOrderDetails(req: Request, res: Response) {
    try {
      const { orderId } = req.params;
      
      // 1. Récupérer la commande sans les items
      const { data: order, error } = await supabase
        .from('orders')
        .select(`
          *, 
          user:users(
            id,
            first_name,
            last_name,
            email,
            phone
          ),
          service:services(
            id,
            name,
            description
          ),
          address:addresses(*)
        `)
        .eq('id', orderId)
        .single();

      if (error) throw error;
      if (!order) return res.status(404).json({ error: 'Order not found' });

      // 2. Récupérer les items séparément
      const items = await OrderSharedMethods.getOrderItems(orderId);

      // 3. Construire la réponse complète
      const completeOrder = {
        ...order,
        items
      };

      res.json({ data: completeOrder });
    } catch (error: any) {
      console.error('[OrderController] Error getting order details:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async getUserOrders(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const { data: orders, error } = await supabase
        .from('orders')
        .select(`
          *,
          service:services(
            id,
            name,
            description
          )
        `)
        .eq('userId', userId)
        .order('createdAt', { ascending: false });

      if (error) throw error;

      // Récupérer les items pour chaque commande
      const completeOrders = await Promise.all(
        orders.map(async (order) => ({
          ...order,
          items: await OrderSharedMethods.getOrderItems(order.id)
        }))
      );

      res.json({ data: completeOrders });
    } catch (error: any) {
      console.error('[OrderController] Error getting user orders:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async getRecentOrders(req: Request, res: Response) {
    try {
      const limit = parseInt(req.query.limit?.toString() || '5');

      const { data, error } = await supabase
        .from('orders')
        .select(`
          *,
          user:users(
            first_name,
            last_name,
            email
          ),
          service:services(
            id,
            name
          ),
          address:addresses(*)
        `)
        .order('createdAt', { ascending: false })
        .limit(limit);

      if (error) throw error;

      res.json({
        success: true,
        data: data
      });
    } catch (error) {
      console.error('Error fetching recent orders:', error);
      res.status(500).json({ 
        success: false,
        error: 'Failed to fetch recent orders'
      });
    }
  }

  static async getOrdersByStatus(req: Request, res: Response) {
    try {
      const { data: orders, error } = await supabase
        .from('orders')
        .select('status');

      if (error) throw error;

      const statusCount = orders.reduce((acc: Record<string, number>, order) => {
        acc[order.status] = (acc[order.status] || 0) + 1;
        return acc;
      }, {});

      res.json({
        success: true,
        data: statusCount
      });
    } catch (error) {
      console.error('Error fetching orders by status:', error);
      res.status(500).json({
        success: false, 
        error: 'Failed to fetch orders by status'
      });
    }
  }

  static async getAllOrders(req: Request, res: Response) {
    try {
      const { page = 1, limit = 20, status, startDate, endDate } = req.query;

      let query = supabase
        .from('orders')
        .select(`
          *,
          user:users(
            id,
            first_name,
            last_name
          ),
          service:services(
            id,
            name,
            description
          )
        `);

      if (status) {
        query = query.eq('status', status as string);
      }

      if (startDate && endDate) {
        query = query
          .gte('createdAt', startDate as string)
          .lte('createdAt', endDate as string);  
      }

      const offset = (Number(page) - 1) * Number(limit);
      const { data: orders, error, count } = await query
        .range(offset, offset + Number(limit) - 1)
        .order('createdAt', { ascending: false });

      if (error) throw error;

      // Récupérer les items pour chaque commande
      const ordersWithItems = await Promise.all(
        orders.map(async (order) => ({
          ...order,
          items: await OrderSharedMethods.getOrderItems(order.id)
        }))
      );

      res.json({
        data: ordersWithItems,
        pagination: {
          page: Number(page),
          limit: Number(limit),
          total: count || 0,
          totalPages: Math.ceil((count || 0) / Number(limit))
        }
      });
    } catch (error: any) {
      console.error('[OrderController] Error getting all orders:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async generateInvoice(req: Request, res: Response) {
    try {
      const { orderId } = req.params;
      
      // Récupérer la commande avec ses détails
      const { data: order, error } = await supabase
        .from('orders')
        .select(`
          *,
          user:users(first_name, last_name, email, phone),
          service:services(name),
          address:addresses(*)
        `)
        .eq('id', orderId)
        .single();

      if (error) throw error;
      if (!order) return res.status(404).json({ error: 'Order not found' });

      const items = await OrderSharedMethods.getOrderItems(orderId);
      const completeOrder = {
        ...order,
        items
      };

      const doc = new PDFDocument();
      res.setHeader('Content-Type', 'application/pdf');
      res.setHeader('Content-Disposition', `attachment; filename=invoice-${orderId}.pdf`);
      
      doc.pipe(res);
      doc.fontSize(25).text('Facture', 100, 50);
      doc.fontSize(12).text(`Commande: ${orderId}`, 100, 100);
      doc.end();
    } catch (error: any) {
      console.error('[OrderController] Error generating invoice:', error);
      res.status(500).json({ error: error.message });
    }
  }
}