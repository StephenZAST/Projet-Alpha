import { Request, Response } from 'express';
import prisma from '../../config/prisma';
import PDFDocument from 'pdfkit';
import { OrderSharedMethods, OrderItemWithArticle } from './shared';
import { OrderQueryService } from '../../services/order.service/orderQuery.service';
import { OrderStatus } from '@prisma/client';

export class OrderQueryController {
  // Endpoint dédié à la recherche par ID
  static async getOrderById(req: Request, res: Response) {
    try {
      const { orderId } = req.params;
      if (!orderId) {
        return res.status(400).json({ success: false, error: 'orderId requis' });
      }
      // Recherche directe par clé primaire
      const order = await OrderQueryService.getOrderDetails(orderId);
      if (!order) {
        return res.status(404).json({ success: false, error: 'Commande non trouvée' });
      }
      res.json({ success: true, data: order });
    } catch (error: any) {
      console.error('[OrderQueryController] getOrderById error:', error);
      res.status(500).json({ success: false, error: 'Erreur serveur', message: error.message });
    }
  }
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
          address: true,
          order_notes: {
            select: {
              id: true,
              note: true,
              created_at: true,
              updated_at: true
            }
          }
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
      // Récupération des paramètres de pagination
      const page = req.query.page ? parseInt(req.query.page as string, 10) : 1;
      const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : 20;
      const status = req.query.status;
      const startDate = req.query.startDate;
      const endDate = req.query.endDate;

      const skip = (page - 1) * limit;
      const where: any = {};
      if (status) where.status = status;
      if (startDate && endDate) {
        where.createdAt = {
          gte: new Date(startDate as string),
          lte: new Date(endDate as string)
        };
      }

      // Récupérer le total avant pagination
      const totalCount = await prisma.orders.count({ where });

      // Récupérer les commandes paginées
      const orders = await prisma.orders.findMany({
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
        take: limit,
        orderBy: { createdAt: 'desc' }
      });

      // Ajouter les items à chaque commande
      const ordersWithItems = await Promise.all(
        orders.map(async (order) => ({
          ...order,
          items: await OrderSharedMethods.getOrderItems(order.id)
        }))
      );

      res.json({
        data: ordersWithItems,
        page,
        limit,
        total: totalCount,
        totalPages: Math.ceil(totalCount / limit)
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

  static async searchOrders(req: Request, res: Response) {
    try {
      const {
        query,
        searchTerm,
        status,
        startDate,
        endDate,
        minAmount,
        maxAmount,
        isFlashOrder,
        page = 1,
        limit = 10,
        sortBy = 'createdAt',
        sortOrder = 'desc'
      } = req.query;

      // Prendre 'searchTerm' si présent, sinon 'query'
      const globalSearch = (searchTerm ?? query) as string;

      const searchParams = {
        searchTerm: globalSearch,
        status: status as OrderStatus,
        startDate: startDate ? new Date(startDate as string) : undefined,
        endDate: endDate ? new Date(endDate as string) : undefined,
        minAmount: minAmount ? Number(minAmount) : undefined,
        maxAmount: maxAmount ? Number(maxAmount) : undefined,
        isFlashOrder: isFlashOrder === 'true',
        pagination: {
          page: Number(page),
          limit: Number(limit)
        },
        sortBy: sortBy as string,
        sortOrder: sortOrder as 'asc' | 'desc'
      };

      const result = await OrderQueryService.searchOrders(searchParams);

      res.json({
        success: true,
        data: result.orders,
        pagination: result.pagination
      });

    } catch (error: any) {
      console.error('[OrderQueryController] Search error:', error);
      res.status(500).json({
        success: false,
        error: 'Erreur lors de la recherche des commandes',
        message: error.message
      });
    }
  }
}