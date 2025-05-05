import { PrismaClient, order_status as OrderStatusEnum, order_status } from '@prisma/client';
import {
  Service,
  Article,
  DashboardStatistics,
  NotificationType,
  OrderStatus as CustomOrderStatus,
  AdminCreateOrderDTO,
  CreateArticleDTO
} from '../models/types';
import { NotificationService } from './notification.service';

const prisma = new PrismaClient();

interface RevenueChartData {
  labels: string[];
  data: number[];
}

export class AdminService {
  static async createService(name: string, price: number, description?: string): Promise<Service> {
    try {
      const service = await prisma.services.create({
        data: {
          name,
          price,
          description,
          created_at: new Date(),
          updated_at: new Date()
        }
      });

      return {
        id: service.id,
        name: service.name,
        price: service.price || 0,
        description: service.description || undefined,
        createdAt: service.created_at || new Date(),
        updatedAt: service.updated_at || new Date()
      };
    } catch (error) {
      console.error('[AdminService] Create service error:', error);
      throw error;
    }
  }

  static async getAllServices(): Promise<Service[]> {
    try {
      const services = await prisma.services.findMany({
        include: {
          service_types: true
        }
      });

      return services.map(service => ({
        id: service.id,
        name: service.name,
        price: service.price || 0,
        description: service.description || undefined,
        createdAt: service.created_at || new Date(),
        updatedAt: service.updated_at || new Date()
      }));
    } catch (error) {
      console.error('[AdminService] Get all services error:', error);
      throw error;
    }
  }

  static async updateService(
    serviceId: string, 
    name: string, 
    price: number, 
    description?: string
  ): Promise<Service> {
    try {
      const service = await prisma.services.update({
        where: { id: serviceId },
        data: {
          name,
          price,
          description,
          updated_at: new Date()
        }
      });

      return {
        id: service.id,
        name: service.name,
        price: service.price || 0,
        description: service.description || undefined,
        createdAt: service.created_at || new Date(),
        updatedAt: service.updated_at || new Date()
      };
    } catch (error) {
      console.error('[AdminService] Update service error:', error);
      throw error;
    }
  }

  static async deleteService(serviceId: string): Promise<void> {
    try {
      await prisma.services.delete({
        where: { id: serviceId }
      });
    } catch (error) {
      console.error('[AdminService] Delete service error:', error);
      throw error;
    }
  }

  static async createArticle(
    name: string,
    basePrice: number,
    categoryId: string,
    description?: string
  ) {
    return await prisma.articles.create({
      data: {
        name,
        basePrice,
        categoryId,
        description
      }
    });
  }

  static async getAllArticles(): Promise<Article[]> {
    try {
      const articles = await prisma.articles.findMany({
        where: {
          isDeleted: false
        },
        include: {
          article_categories: true
        },
        orderBy: {
          createdAt: 'desc'
        }
      });

      return articles.map(article => ({
        id: article.id,
        name: article.name,
        categoryId: article.categoryId || '',
        description: article.description || undefined,
        basePrice: Number(article.basePrice),
        premiumPrice: Number(article.premiumPrice || 0),
        createdAt: article.createdAt || new Date(),
        updatedAt: article.updatedAt || new Date()
      }));
    } catch (error) {
      console.error('[AdminService] Get all articles error:', error);
      throw error;
    }
  }

  static async updateArticle(
    articleId: string,
    data: Partial<CreateArticleDTO>
  ) {
    return await prisma.articles.update({
      where: { id: articleId },
      data
    });
  }

  static async deleteArticle(articleId: string): Promise<void> {
    try {
      await prisma.articles.update({
        where: { id: articleId },
        data: {
          isDeleted: true,
          updatedAt: new Date()
        }
      });
    } catch (error) {
      console.error('[AdminService] Delete article error:', error);
      throw error;
    }
  }

  static async getDashboardStatistics(): Promise<DashboardStatistics> {
    try {
      const [totalOrders, totalRevenue, totalCustomers, recentOrders] = await Promise.all([
        prisma.orders.count(),
        prisma.orders.aggregate({
          _sum: {
            totalAmount: true
          },
          where: {
            status: 'DELIVERED'
          }
        }),
        prisma.users.count({
          where: {
            role: 'CLIENT'
          }
        }),
        prisma.orders.findMany({
          take: 5,
          orderBy: {
            createdAt: 'desc'
          },
          include: {
            user: {
              select: {
                id: true,
                email: true,
                first_name: true,
                last_name: true
              }
            },
            order_items: {
              include: {
                article: true
              }
            },
            service_types: true
          }
        })
      ]);

      const ordersByStatus = await prisma.orders.groupBy({
        by: ['status'],
        _count: true
      });

      const statusCounts = ordersByStatus.reduce((acc, curr) => {
        if (curr.status) {
          acc[curr.status] = curr._count;
        }
        return acc;
      }, {} as Record<string, number>);

      return {
        totalOrders,
        totalRevenue: Number(totalRevenue._sum.totalAmount || 0),
        totalCustomers,
        recentOrders: recentOrders.map(order => ({
          id: order.id,
          totalAmount: Number(order.totalAmount || 0),
          status: order.status || 'PENDING',
          createdAt: order.createdAt || new Date(),
          service: {
            name: order.service_types?.name || ''
          },
          user: order.user ? {
            id: order.user.id,
            email: order.user.email,
            firstName: order.user.first_name,
            lastName: order.user.last_name
          } : null
        })),
        ordersByStatus: statusCounts
      };
    } catch (error) {
      console.error('[AdminService] Get dashboard statistics error:', error);
      throw error;
    }
  }

  static async updateAffiliateStatus(
    affiliateId: string,
    status: order_status
  ) {
    return await prisma.affiliate_profiles.update({
      where: { id: affiliateId },
      data: { status: status as any }
    });
  }

  static async configureCommissions(commissionRate: number, rewardPoints: number) {
    return await prisma.affiliate_levels.create({
      data: {
        name: 'Default',
        minEarnings: 0,
        commissionRate: commissionRate
      }
    });
  }

  static async configureRewards(rewardPoints: number, rewardType: string) {
    return await prisma.price_configurations.create({
      data: {
        id: 'rewards_config',
      }
    });
  }

  static async getAllOrders(
    page: number,
    limit: number,
    params?: {
      status?: order_status;
      sortField?: string;
      sortOrder?: 'asc' | 'desc';
    }
  ) {
    const skip = (page - 1) * limit;
    
    const orders = await prisma.orders.findMany({
      skip,
      take: limit,
      where: params?.status ? { status: params.status } : undefined,
      orderBy: params?.sortField ? {
        [params.sortField]: params.sortOrder || 'desc'
      } : undefined,
      include: {
        user: true,
        order_items: {
          include: {
            article: true
          }
        }
      }
    });

    const total = await prisma.orders.count({
      where: params?.status ? { status: params.status } : undefined
    });

    return {
      orders,
      total,
      pages: Math.ceil(total / limit)
    };
  }

  static async createOrderForCustomer(
    userId: string,
    orderData: {
      items: Array<{ articleId: string; quantity: number }>;
      serviceTypeId: string;
      addressId: string;
      collectionDate?: Date;
      deliveryDate?: Date;
    }
  ): Promise<any> {
    try {
      const user = await prisma.users.findUnique({
        where: { id: userId }
      });

      if (!user) throw new Error('User not found');

      const order = await prisma.orders.create({
        data: {
          userId,
          service_type_id: orderData.serviceTypeId,
          addressId: orderData.addressId,
          status: 'PENDING',
          collectionDate: orderData.collectionDate,
          deliveryDate: orderData.deliveryDate,
          createdAt: new Date(),
          updatedAt: new Date(),
          order_items: {
        create: orderData.items.map(item => ({
          articleId: item.articleId,
          quantity: item.quantity,
          serviceId: orderData.serviceTypeId,
          unitPrice: 0,
          createdAt: new Date(),
          updatedAt: new Date()
        }))
          }
        },
        include: {
          order_items: {
        include: {
          article: true
        }
          }
        }
      });

      await NotificationService.sendNotification(
        userId,
        NotificationType.ORDER_CREATED,
        {
          title: 'Nouvelle commande créée',
          message: `Votre commande #${order.id} a été créée avec succès`,
          data: { orderId: order.id }
        }
      );

      return order;
    } catch (error) {
      console.error('[AdminService] Create order for customer error:', error);
      throw error;
    }
  }

  static async getRevenueChartData(): Promise<RevenueChartData> {
    try {
      const revenue = await prisma.orders.findMany({
        where: {
          status: 'DELIVERED'
        },
        select: {
          createdAt: true,
          totalAmount: true
        },
        orderBy: {
          createdAt: 'asc'
        }
      });

      const chartData = revenue.reduce((acc, order) => {
        const date = order.createdAt?.toISOString().split('T')[0] || '';
        const amount = Number(order.totalAmount || 0);
        
        const dateIndex = acc.labels.indexOf(date);
        if (dateIndex === -1) {
          acc.labels.push(date);
          acc.data.push(amount);
        } else {
          acc.data[dateIndex] += amount;
        }
        
        return acc;
      }, { labels: [] as string[], data: [] as number[] });

      return chartData;
    } catch (error) {
      console.error('[AdminService] Get revenue chart data error:', error);
      return { labels: [], data: [] };
    }
  }

  static async getStatistics() {
    const [orders, totalRevenue, totalCustomers, recentOrders, orderStatusCounts] = await Promise.all([
      prisma.orders.count(),
      prisma.orders.aggregate({
        _sum: {
          totalAmount: true
        },
        where: {
          status: 'DELIVERED'
        }
      }),
      prisma.users.count({
        where: {
          role: 'CLIENT'
        }
      }),
      prisma.orders.findMany({
        take: 5,
        orderBy: {
          createdAt: 'desc'
        },
        include: {
          user: true,
          service_types: true
        }
      }),
      prisma.orders.groupBy({
        by: ['status'],
        _count: true
      })
    ]);

    const statusCounts = orderStatusCounts.reduce((acc, curr) => {
      if (curr.status) {
        acc[curr.status] = curr._count;
      }
      return acc;
    }, {} as Record<string, number>);

    return {
      totalOrders: orders,
      totalRevenue: Number(totalRevenue._sum.totalAmount || 0),
      totalCustomers,
      recentOrders,
      ordersByStatus: statusCounts
    };
  }
}
