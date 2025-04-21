import { Request, Response } from 'express';
import prisma from '../../config/prisma';
import PDFDocument from 'pdfkit';
import { OrderSharedMethods, OrderItemWithArticle } from './shared';

export class OrderQueryController {
  static getOrderItems = OrderSharedMethods.getOrderItems;

  static async getOrderDetails(req: Request, res: Response) {
    try {
      const { orderId } = req.params;
      
      const order = await prisma.orders.findUnique({
        where: { id: orderId },
        include: {
          user: {
            select: {
              id: true,
              first_name: true,
              last_name: true,
              email: true,
              phone: true
            }
          },
          service_types: {  // Changé de service à service_types
            select: {
              id: true,
              name: true,
              description: true
            }
          },
          address: true
        }
      });

      if (!order) return res.status(404).json({ error: 'Order not found' });

      const items = await OrderSharedMethods.getOrderItems(orderId);
      const completeOrder = { ...order, items };

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

      const orders = await prisma.orders.findMany({
        where: { userId },
        include: {
          service_types: {  // Changé de service à service_types
            select: {
              id: true,
              name: true,
              description: true
            }
          }
        },
        orderBy: { createdAt: 'desc' }
      });

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

      const orders = await prisma.orders.findMany({
        include: {
          user: {
            select: {
              first_name: true,
              last_name: true,
              email: true
            }
          },
          service_types: {
            select: {
              id: true,
              name: true
            }
          },
          address: true
        },
        orderBy: { createdAt: 'desc' },
        take: limit
      });

      res.json({
        success: true,
        data: orders
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
      const orders = await prisma.orders.findMany({
        select: { status: true },
        where: {
          status: {
            not: null
          }
        }
      });

      const statusCount = orders.reduce((acc: Record<string, number>, order) => {
        // Vérification que le status n'est pas null avant de l'utiliser comme index
        if (order.status) {
          acc[order.status] = (acc[order.status] || 0) + 1;
        }
        return acc;
      }, {} as Record<string, number>);

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
      const { 
        page = 1, 
        limit = 20, 
        status, 
        startDate, 
        endDate 
      } = req.query;

      const skip = (Number(page) - 1) * Number(limit);
      
      const where: any = {};
      if (status) where.status = status;
      if (startDate && endDate) {
        where.createdAt = {
          gte: new Date(startDate as string),
          lte: new Date(endDate as string)
        };
      }

      const [orders, totalCount] = await prisma.$transaction([
        prisma.orders.findMany({
          where,
          include: {
            user: {
              select: {
                id: true,
                first_name: true,
                last_name: true
              }
            },
            service_types: {
              select: {
                id: true,
                name: true,
                description: true
              }
            }
          },
          skip,
          take: Number(limit),
          orderBy: { createdAt: 'desc' }
        }),
        prisma.orders.count({ where })
      ]);

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
          total: totalCount,
          totalPages: Math.ceil(totalCount / Number(limit))
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
      
      const order = await prisma.orders.findUnique({
        where: { id: orderId },
        include: {
          user: {
            select: {
              first_name: true,
              last_name: true,
              email: true,
              phone: true
            }
          },
          service_types: {
            select: {
              name: true
            }
          },
          address: true
        }
      });

      if (!order) return res.status(404).json({ error: 'Order not found' });

      const items = await OrderSharedMethods.getOrderItems(orderId);
      const completeOrder = { ...order, items };

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