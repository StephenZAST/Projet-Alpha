import { PrismaClient, Prisma } from '@prisma/client';
import { Order, OrderStatus } from '../../models/types';

const prisma = new PrismaClient();

interface OrderSearchParams {
  searchTerm?: string;
  serviceTypeId?: string;
  paymentMethod?: string;
  status?: OrderStatus;
  startDate?: Date;
  endDate?: Date;
  userId?: string;
  minAmount?: number;
  maxAmount?: number;
  isFlashOrder?: boolean;
  pagination: {
    page: number;
    limit: number;
  };
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

export class OrderQueryService {
  private static readonly orderInclude = {
    users: {
      select: {
        id: true,
        email: true,
        first_name: true,
        last_name: true,
        phone: true,
        role: true,
        referral_code: true
      }
    },
    services: {
      select: {
        id: true,
        name: true,
        price: true,
        description: true
      }
    },
    addresses: {
      select: {
        id: true,
        name: true,
        street: true,
        city: true,
        postal_code: true,
        gps_latitude: true,
        gps_longitude: true,
        is_default: true
      }
    },
    order_items: {
      include: {
        article: {
          include: {
            article_categories: true
          }
        }
      }
    }
  };

  static async getUserOrders(userId: string): Promise<Order[]> {
    try {
      const orders = await prisma.orders.findMany({
        where: {
          userId
        },
        include: this.orderInclude,
        orderBy: {
          createdAt: 'desc'
        }
      });

      return this.formatOrders(orders);
    } catch (error) {
      console.error('Error fetching user orders:', error);
      throw error;
    }
  }

  static async getOrderDetails(orderId: string): Promise<Order> {
    try {
      const order = await prisma.orders.findUnique({
        where: {
          id: orderId
        },
        include: this.orderInclude
      });

      if (!order) {
        throw new Error('Order not found');
      }

      return this.formatOrder(order);
    } catch (error) {
      console.error('Error fetching order details:', error);
      throw error;
    }
  }

  static async getRecentOrders(limit: number = 5): Promise<Order[]> {
    try {
      const orders = await prisma.orders.findMany({
        take: limit,
        include: this.orderInclude,
        orderBy: {
          createdAt: 'desc'
        }
      });

      return this.formatOrders(orders);
    } catch (error) {
      console.error('Error fetching recent orders:', error);
      throw error;
    }
  }

  static async getOrdersByStatus(): Promise<Record<string, number>> {
    try {
      const orders = await prisma.orders.groupBy({
        by: ['status'],
        _count: {
          status: true
        }
      });

      return orders.reduce((acc, curr) => {
        if (curr.status) {
          acc[curr.status] = curr._count.status;
        }
        return acc;
      }, {} as Record<string, number>);
    } catch (error) {
      console.error('Error getting orders by status:', error);
      throw error;
    }
  }

  static async searchOrders(params: OrderSearchParams) {
    try {
      const where: any = {};

      // Recherche textuelle globale
      if (params.searchTerm) {
        where.OR = [
          { id: { contains: params.searchTerm, mode: 'insensitive' } },
          { 'user.first_name': { contains: params.searchTerm, mode: 'insensitive' } },
          { 'user.last_name': { contains: params.searchTerm, mode: 'insensitive' } },
          { 'user.email': { contains: params.searchTerm, mode: 'insensitive' } },
          { 'user.phone': { contains: params.searchTerm, mode: 'insensitive' } },
          { 
            order_items: {
              some: {
                article: {
                  name: { contains: params.searchTerm, mode: 'insensitive' }
                }
              }
            }
          }
        ];
      }

      // Ajout de nouveaux filtres
      where.AND = [];

      // Filtre par type de service
      if (params.serviceTypeId) {
        where.AND.push({ service_type_id: params.serviceTypeId });
      }

      // Filtre par méthode de paiement
      if (params.paymentMethod) {
        where.AND.push({ paymentMethod: params.paymentMethod });
      }

      // Filtre par montant
      if (params.minAmount || params.maxAmount) {
        where.AND.push({
          totalAmount: {
            ...(params.minAmount && { gte: new Prisma.Decimal(params.minAmount) }),
            ...(params.maxAmount && { lte: new Prisma.Decimal(params.maxAmount) })
          }
        });
      }

      // Filtre par date
      if (params.startDate || params.endDate) {
        where.AND.push({
          createdAt: {
            ...(params.startDate && { gte: params.startDate }),
            ...(params.endDate && { lte: params.endDate })
          }
        });
      }

      // Filtre par statut
      if (params.status) {
        where.AND.push({ status: params.status });
      }

      // Filtre par type de commande (flash/standard)
      if (params.isFlashOrder !== undefined) {
        where.AND.push({
          order_metadata: {
            is_flash_order: params.isFlashOrder
          }
        });
      }

      // Ajouter les nouveaux includes pour plus de détails
      const include = {
        user: {
          select: {
            id: true,
            email: true,
            first_name: true,
            last_name: true,
            phone: true
          }
        },
        address: true,
        service_types: true,
        order_items: {
          include: {
            article: {
              include: {
                article_categories: true
              }
            }
          }
        },
        order_metadata: true
      };

      // Exécuter la requête avec pagination
      const [orders, total] = await Promise.all([
        prisma.orders.findMany({
          where,
          include,
          skip: (params.pagination.page - 1) * params.pagination.limit,
          take: params.pagination.limit,
          orderBy: {
            [params.sortBy || 'createdAt']: params.sortOrder || 'desc'
          }
        }),
        prisma.orders.count({ where })
      ]);

      return {
        orders: orders.map(this.formatOrder),
        pagination: {
          total,
          page: params.pagination.page,
          limit: params.pagination.limit,
          totalPages: Math.ceil(total / params.pagination.limit)
        }
      };

    } catch (error) {
      console.error('[OrderQueryService] Search error:', error);
      throw error;
    }
  }

  private static formatOrder(order: any): Order {
    return {
      id: order.id,
      userId: order.userId,
      service_id: order.serviceId || '',
      address_id: order.addressId || '',
      status: order.status || 'PENDING',
      isRecurring: order.isRecurring || false,
      recurrenceType: order.recurrenceType || 'NONE',
      totalAmount: Number(order.totalAmount || 0),
      collectionDate: order.collectionDate ? new Date(order.collectionDate) : null,
      deliveryDate: order.deliveryDate ? new Date(order.deliveryDate) : null,
      createdAt: order.createdAt || new Date(),
      updatedAt: order.updatedAt || new Date(),
      service_type_id: order.service_type_id,
      paymentStatus: order.status,
      paymentMethod: order.paymentMethod || 'CASH',
      items: order.order_items?.map((item: any) => ({
        id: item.id,
        orderId: item.orderId,
        articleId: item.articleId,
        serviceId: item.serviceId,
        quantity: item.quantity,
        unitPrice: Number(item.unitPrice),
        isPremium: item.isPremium || false,
        article: item.article ? {
          id: item.article.id,
          categoryId: item.article.categoryId || '',
          name: item.article.name,
          description: item.article.description || undefined,
          basePrice: Number(item.article.basePrice),
          premiumPrice: Number(item.article.premiumPrice || 0),
          createdAt: item.article.createdAt || new Date(),
          updatedAt: item.article.updatedAt || new Date()
        } : undefined,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt
      })) || []
    };
  }

  private static formatOrders(orders: any[]): Order[] {
    return orders.map(order => this.formatOrder(order));
  }
}