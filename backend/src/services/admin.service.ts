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
      startDate?: string;
      endDate?: string;
      paymentMethod?: string;
      serviceTypeId?: string;
      minAmount?: string;
      maxAmount?: string;
      isFlashOrder?: boolean;
      query?: string;
      // paymentStatus?: string; // supprimé
      affiliateCode?: string;
      recurrenceType?: string;
      city?: string;
      postalCode?: string;
      collectionDateStart?: string;
      collectionDateEnd?: string;
      deliveryDateStart?: string;
      deliveryDateEnd?: string;
      isRecurring?: boolean;
      sortByNextRecurrenceDate?: 'asc' | 'desc';
    }
  ) {
    const skip = (page - 1) * limit;
    // Construction dynamique du filtre avancé
    const where: any = {};

    // Statut (inclut le filtre flash si combiné)
    if (params?.status) {
      where.status = params.status;
    }

    // Type de commande flash (statut DRAFT)
    if (typeof params?.isFlashOrder === 'boolean') {
      if (params.isFlashOrder) {
        where.status = 'DRAFT';
      } else {
        if (!params.status) {
          where.status = { not: 'DRAFT' };
        }
      }
    }

    // Type de service dynamique
    if (params?.serviceTypeId) {
      where.service_type_id = params.serviceTypeId;
    }

    // Méthode de paiement
    if (params?.paymentMethod) {
      where.paymentMethod = params.paymentMethod;
    }

    // Statut de paiement supprimé (non présent dans le modèle)

    // Code affilié
    if (params?.affiliateCode) {
      where.affiliateCode = params.affiliateCode;
    }

    // Type de récurrence
    if (params?.recurrenceType) {
      where.recurrenceType = params.recurrenceType;
    }

    // Ville
    if (params?.city) {
      where.address = { ...where.address, city: { contains: params.city, mode: 'insensitive' } };
    }

    // Code postal
    if (params?.postalCode) {
      where.address = { ...where.address, postal_code: { contains: params.postalCode, mode: 'insensitive' } };
    }

    // Plage de dates de collecte
    if (params?.collectionDateStart) {
      where.collectionDate = { ...where.collectionDate, gte: new Date(params.collectionDateStart) };
    }
    if (params?.collectionDateEnd) {
      where.collectionDate = { ...where.collectionDate, lte: new Date(params.collectionDateEnd) };
    }

    // Plage de dates de livraison
    if (params?.deliveryDateStart) {
      where.deliveryDate = { ...where.deliveryDate, gte: new Date(params.deliveryDateStart) };
    }
    if (params?.deliveryDateEnd) {
      where.deliveryDate = { ...where.deliveryDate, lte: new Date(params.deliveryDateEnd) };
    }

    // Commande récurrente
    if (typeof params?.isRecurring === 'boolean') {
      where.isRecurring = params.isRecurring;
    }

    // Montant
    if (params?.minAmount) {
      where.totalAmount = { ...where.totalAmount, gte: Number(params.minAmount) };
    }
    if (params?.maxAmount) {
      where.totalAmount = { ...where.totalAmount, lte: Number(params.maxAmount) };
    }

    // Recherche globale (sur user, email, etc.)
    if (params?.query) {
      where.OR = [
        {
          user: {
            is: {
              OR: [
                { first_name: { contains: params.query, mode: 'insensitive' } },
                { last_name: { contains: params.query, mode: 'insensitive' } },
                { email: { contains: params.query, mode: 'insensitive' } }
              ]
            }
          }
        }
      ];
    }

    // Gestion du tri par date de récurrence si demandé
    let orderBy: any = params?.sortField ? {
      [params.sortField]: params.sortOrder || 'desc'
    } : { createdAt: 'desc' };
    if (params?.sortByNextRecurrenceDate) {
      orderBy = { nextRecurrenceDate: params.sortByNextRecurrenceDate };
    }

    const orders = await prisma.orders.findMany({
      skip,
      take: limit,
      where,
      orderBy,
      include: {
        user: true,
        order_items: {
          include: {
            article: true
          }
        },
        address: true
      }
    });

    const total = await prisma.orders.count({ where });

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

  static async getAdminProfile(adminId: string) {
    try {
      console.log('[AdminService] Looking for user with ID:', adminId);
      
      // Chercher l'utilisateur sans restriction de rôle d'abord
      const user = await prisma.users.findUnique({
        where: { id: adminId },
        select: {
          id: true,
          email: true,
          first_name: true,
          last_name: true,
          phone: true,
          role: true,
          created_at: true,
          updated_at: true
        }
      });
      
      console.log('[AdminService] User found:', user);
      
      if (!user) {
        throw new Error(`User with ID ${adminId} not found`);
      }
      
      // Vérifier que l'utilisateur a un rôle d'administration (plus flexible)
      const adminRoles = ['ADMIN', 'SUPER_ADMIN']; // On peut ajouter d'autres rôles si nécessaire
      if (!adminRoles.includes(user.role as string)) {
        console.log(`[AdminService] User ${user.email} has role ${user.role}, which is not an admin role`);
        throw new Error(`User ${user.email} does not have admin privileges`);
      }

      console.log('[AdminService] Admin profile loaded successfully for:', user.email);

      return {
        id: user.id,
        email: user.email,
        firstName: user.first_name || '',
        lastName: user.last_name || '',
        phone: user.phone || '',
        role: user.role,
        createdAt: user.created_at || new Date(),
        updatedAt: user.updated_at || new Date()
      };
    } catch (error) {
      console.error('[AdminService] Get admin profile error:', error);
      throw error;
    }
  }

  static async updateAdminProfile(adminId: string, data: {
    firstName?: string;
    lastName?: string;
    phone?: string;
    email?: string;
  }) {
    try {
      const updateData: any = {
        updated_at: new Date()
      };

      if (data.firstName !== undefined) updateData.first_name = data.firstName;
      if (data.lastName !== undefined) updateData.last_name = data.lastName;
      if (data.phone !== undefined) updateData.phone = data.phone;
      if (data.email !== undefined) updateData.email = data.email;

      const admin = await prisma.users.update({
        where: { 
          id: adminId
          // Pas de restriction de rôle ici - la validation est faite au niveau du middleware d'autorisation
        },
        data: updateData,
        select: {
          id: true,
          email: true,
          first_name: true,
          last_name: true,
          phone: true,
          role: true,
          created_at: true,
          updated_at: true
        }
      });

      return {
        id: admin.id,
        email: admin.email,
        firstName: admin.first_name || '',
        lastName: admin.last_name || '',
        phone: admin.phone || '',
        role: admin.role,
        createdAt: admin.created_at || new Date(),
        updatedAt: admin.updated_at || new Date()
      };
    } catch (error) {
      console.error('[AdminService] Update admin profile error:', error);
      throw error;
    }
  }

  static async updateAdminPassword(adminId: string, currentPassword: string, newPassword: string) {
    try {
      // First verify current password
      const admin = await prisma.users.findUnique({
        where: { 
          id: adminId
          // Pas de restriction de rôle ici - la validation est faite au niveau du middleware d'autorisation
        },
        select: {
          id: true,
          password: true
        }
      });

      if (!admin) {
        throw new Error('Admin not found');
      }

      // Import bcrypt for password verification
      const bcrypt = require('bcrypt');
      
      const isCurrentPasswordValid = await bcrypt.compare(currentPassword, admin.password);
      if (!isCurrentPasswordValid) {
        throw new Error('Current password is incorrect');
      }

      // Hash new password
      const saltRounds = 10;
      const hashedNewPassword = await bcrypt.hash(newPassword, saltRounds);

      // Update password
      await prisma.users.update({
        where: { id: adminId },
        data: {
          password: hashedNewPassword,
          updated_at: new Date()
        }
      });

      return { success: true, message: 'Password updated successfully' };
    } catch (error) {
      console.error('[AdminService] Update admin password error:', error);
      throw error;
    }
  }
}
