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

  static async getRevenueChartData(
    period: 'day' | 'week' | 'month' | 'year' = 'month'
  ): Promise<Array<{ date: string; amount: number }>> {
    try {
      const now = new Date();
      let startDate: Date;

      switch (period) {
        case 'day':
          startDate = new Date(now.setHours(0, 0, 0, 0));
          break;
        case 'week':
          startDate = new Date(now.setDate(now.getDate() - 7));
          break;
        case 'month':
          startDate = new Date(now.setMonth(now.getMonth() - 1));
          break;
        case 'year':
          startDate = new Date(now.setFullYear(now.getFullYear() - 1));
          break;
      }

      const revenueData = await prisma.orders.groupBy({
        by: ['createdAt'],
        where: {
          status: 'DELIVERED',
          createdAt: {
            gte: startDate
          }
        },
        _sum: {
          totalAmount: true
        }
      });

      return revenueData.map(data => ({
        date: data.createdAt?.toISOString().split('T')[0] || '', 
        amount: Number(data._sum.totalAmount || 0)
      }));
    } catch (error) {
      console.error('[AdminService] Get revenue chart data error:', error);
      throw error;
    }
  }

  static async getStatistics() {
    const [totalRevenue, totalCustomers] = await Promise.all([
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
      })
    ]);

    return {
      totalRevenue: Number(totalRevenue._sum.totalAmount || 0),
      totalCustomers
    };
  }
}
