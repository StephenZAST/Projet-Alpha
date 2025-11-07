import { PrismaClient } from '@prisma/client';
import { Order } from '../../models/types';

const prisma = new PrismaClient();

/**
 * 📱 Service de requêtes de commandes pour le CLIENT APP
 * 
 * Ce service est spécifiquement conçu pour l'application client mobile
 * et enrichit les données avec des informations supplémentaires comme
 * le compteur d'articles, sans perturber les autres applications.
 */
export class ClientOrderQueryService {
  
  /**
   * Récupère les commandes d'un utilisateur avec enrichissement pour le client
   * Ajoute automatiquement le compteur d'articles (itemsCount)
   */
  static async getUserOrdersEnriched(userId: string): Promise<any[]> {
    try {
      const orders = await prisma.orders.findMany({
        where: {
          userId
        },
        include: {
          user: {
            select: {
              id: true,
              email: true,
              first_name: true,
              last_name: true,
              phone: true
            }
          },
          service_types: {
            select: {
              id: true,
              name: true,
              description: true
            }
          },
          address: {
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
          },
          order_notes: {
            select: {
              id: true,
              note: true,
              created_at: true,
              updated_at: true
            }
          },
          order_metadata: true,
          pricing: true
        },
        orderBy: {
          createdAt: 'desc'
        }
      });

      // Enrichir chaque commande avec le compteur d'articles
      return Promise.all(orders.map(order => this.enrichOrderForClient(order)));
    } catch (error) {
      console.error('[ClientOrderQueryService] Error fetching user orders:', error);
      throw error;
    }
  }

  /**
   * Récupère une commande par ID avec enrichissement pour le client
   */
  static async getOrderByIdEnriched(orderId: string): Promise<any> {
    try {
      const order = await prisma.orders.findUnique({
        where: {
          id: orderId
        },
        include: {
          user: {
            select: {
              id: true,
              email: true,
              first_name: true,
              last_name: true,
              phone: true
            }
          },
          service_types: {
            select: {
              id: true,
              name: true,
              description: true
            }
          },
          address: {
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
          },
          order_notes: {
            select: {
              id: true,
              note: true,
              created_at: true,
              updated_at: true
            }
          },
          order_metadata: true,
          pricing: true
        }
      });

      if (!order) {
        throw new Error('Order not found');
      }

      return this.enrichOrderForClient(order);
    } catch (error) {
      console.error('[ClientOrderQueryService] Error fetching order details:', error);
      throw error;
    }
  }

  /**
   * Récupère les commandes récentes avec enrichissement
   */
  static async getRecentOrdersEnriched(userId: string, limit: number = 5): Promise<any[]> {
    try {
      const orders = await prisma.orders.findMany({
        where: {
          userId
        },
        take: limit,
        include: {
          user: {
            select: {
              id: true,
              email: true,
              first_name: true,
              last_name: true,
              phone: true
            }
          },
          service_types: {
            select: {
              id: true,
              name: true,
              description: true
            }
          },
          address: true,
          order_items: {
            include: {
              article: {
                include: {
                  article_categories: true
                }
              }
            }
          },
          order_metadata: true,
          pricing: true
        },
        orderBy: {
          createdAt: 'desc'
        }
      });

      return Promise.all(orders.map(order => this.enrichOrderForClient(order)));
    } catch (error) {
      console.error('[ClientOrderQueryService] Error fetching recent orders:', error);
      throw error;
    }
  }

  /**
   * Enrichit une commande avec des données supplémentaires pour le client
   * - Ajoute itemsCount (nombre d'articles)
   * - Formate les items avec les noms d'articles
   * - Ajoute des métadonnées utiles
   */
  private static async enrichOrderForClient(order: any): Promise<any> {
    console.log('[ClientOrderQueryService] 🔄 Enriching order:', order.id);
    console.log('[ClientOrderQueryService] 📦 Raw order_items count:', order.order_items?.length || 0);
    
    // 🔍 Récupérer les services pour chaque item
    const itemsWithServices = await Promise.all(
      (order.order_items || []).map(async (item: any, index: number) => {
        console.log(`[ClientOrderQueryService] 🔍 Item ${index + 1}:`, {
          itemId: item.id,
          serviceId: item.serviceId,
          articleName: item.article?.name
        });

        // Récupérer le service associé à cet item
        const service = await prisma.services.findUnique({
          where: { id: item.serviceId },
          select: {
            id: true,
            name: true,
            description: true,
            service_type_id: true,
            service_types: {
              select: {
                id: true,
                name: true,
                description: true
              }
            }
          }
        });

        console.log(`[ClientOrderQueryService] 📋 Service found for item ${index + 1}:`, {
          serviceId: service?.id,
          serviceName: service?.name,
          serviceTypeName: service?.service_types?.name
        });

        return {
          id: item.id,
          orderId: item.orderId,
          articleId: item.articleId,
          serviceId: item.serviceId,
          quantity: item.quantity,
          unitPrice: Number(item.unitPrice),
          isPremium: item.isPremium || false,
          weight: item.weight ? Number(item.weight) : null,
          
          // 🎯 Informations de l'article
          article: item.article ? {
            id: item.article.id,
            categoryId: item.article.categoryId || '',
            name: item.article.name,
            description: item.article.description || undefined,
            basePrice: Number(item.article.basePrice),
            premiumPrice: Number(item.article.premiumPrice || 0),
            category: item.article.article_categories ? {
              id: item.article.article_categories.id,
              name: item.article.article_categories.name,
              description: item.article.article_categories.description
            } : null,
            createdAt: item.article.createdAt || new Date(),
            updatedAt: item.article.updatedAt || new Date()
          } : null,
          
          // ✅ Informations du service (nouveau)
          service: service ? {
            id: service.id,
            name: service.name,
            description: service.description,
            serviceTypeId: service.service_type_id,
            serviceType: service.service_types ? {
              id: service.service_types.id,
              name: service.service_types.name,
              description: service.service_types.description
            } : null
          } : null,
          
          createdAt: item.createdAt,
          updatedAt: item.updatedAt
        };
      })
    );

    const items = itemsWithServices;

    return {
      id: order.id,
      userId: order.userId,
      addressId: order.addressId,
      affiliateCode: order.affiliateCode,
      status: order.status || 'PENDING',
      isRecurring: order.isRecurring || false,
      recurrenceType: order.recurrenceType || 'NONE',
      nextRecurrenceDate: order.nextRecurrenceDate,
      totalAmount: Number(order.totalAmount || 0),
      collectionDate: order.collectionDate,
      deliveryDate: order.deliveryDate,
      createdAt: order.createdAt || new Date(),
      updatedAt: order.updatedAt || new Date(),
      serviceId: order.serviceId,
      service_type_id: order.service_type_id,
      paymentMethod: order.paymentMethod || 'CASH',
      
      // 🎯 Données enrichies pour le client
      itemsCount: items.length,  // ✅ Compteur d'articles
      items: items,
      
      // Relations
      user: order.user ? {
        id: order.user.id,
        email: order.user.email,
        first_name: order.user.first_name,
        last_name: order.user.last_name,
        phone: order.user.phone
      } : null,
      
      service_types: order.service_types ? {
        id: order.service_types.id,
        name: order.service_types.name,
        description: order.service_types.description
      } : null,
      
      address: order.address ? {
        id: order.address.id,
        name: order.address.name,
        street: order.address.street,
        city: order.address.city,
        postal_code: order.address.postal_code,
        gps_latitude: order.address.gps_latitude ? Number(order.address.gps_latitude) : null,
        gps_longitude: order.address.gps_longitude ? Number(order.address.gps_longitude) : null,
        is_default: order.address.is_default
      } : null,
      
      order_metadata: order.order_metadata,
      
      note: order.order_notes && order.order_notes.length > 0 
        ? order.order_notes[0].note 
        : null,
      
      // ✅ NOUVEAU - Données de pricing (prix manuel ajusté par admin)
      manualPrice: order.pricing?.manual_price ? Number(order.pricing.manual_price) : null,
      originalPrice: Number(order.totalAmount || 0),  // Le prix original est le totalAmount
      discountPercentage: order.pricing?.manual_price && order.totalAmount
        ? Math.round(((Number(order.totalAmount) - Number(order.pricing.manual_price)) / Number(order.totalAmount)) * 100 * 100) / 100
        : null,
      isPaid: order.pricing?.is_paid || false,
      paidAt: order.pricing?.paid_at,
      pricingReason: order.pricing?.reason,
      
      // 🎯 PRIX À AFFICHER - Alterne entre manualPrice et totalAmount
      displayPrice: order.pricing?.manual_price 
        ? Number(order.pricing.manual_price)  // Si prix manuel existe, l'utiliser
        : Number(order.totalAmount || 0)      // Sinon, utiliser le prix original
    };
  }
}
