import { PrismaClient } from '@prisma/client';
import { OrderArchiveResponse, OrderArchive, OrderStatus, PaymentStatus, PaymentMethod, RecurrenceType, Service } from '../models/types';

const prisma = new PrismaClient();

export class ArchiveService {
  /**
   * Archive une commande et ses items (manuel)
   */
  static async archiveOrder(orderId: string, userId: string, isAdmin: boolean): Promise<void> {
    // Récupérer la commande avec items
    const order = await prisma.orders.findUnique({
      where: { id: orderId },
      include: { order_items: true }
    });
    if (!order) throw new Error('Commande introuvable');
    if (!isAdmin && order.userId !== userId) throw new Error('Non autorisé');

    // Vérifier si une archive existe déjà pour cet id
    const alreadyArchived = await prisma.orders_archive.findUnique({ where: { id: orderId } });
    if (alreadyArchived) {
      // On supprime l'archive existante pour écraser proprement
      await prisma.orders_archive.delete({ where: { id: orderId } });
    }

    // Copier la commande dans orders_archive
    await prisma.orders_archive.create({
      data: {
        id: order.id,
        address_id: order.addressId,
        affiliatecode: order.affiliateCode,
        status: order.status ?? '',
        isrecurring: order.isRecurring,
        recurrencetype: order.recurrenceType,
        nextrecurrencedate: order.nextRecurrenceDate,
        totalAmount: order.totalAmount ?? 0,
        collectiondate: order.collectionDate,
        deliverydate: order.deliveryDate,
        createdAt: order.createdAt,
        updatedat: order.updatedAt,
        service_id: order.serviceId,
        service_type_id: order.service_type_id,
        userId: order.userId,
        archived_at: new Date(),
      }
    });

    // Copier les items dans order_items_archive si la table existe
    if (order.order_items && order.order_items.length > 0) {
      // Vérifier si la table order_items_archive existe dans Prisma
      // Si oui, insérer les items
      try {
        await prisma.$executeRaw`INSERT INTO order_items_archive (id, "orderId", "articleId", quantity, "unitPrice", weight, created_at, updated_at)
          SELECT id, "orderId", "articleId", quantity, "unitPrice", weight, created_at, updated_at FROM order_items WHERE "orderId" = ${orderId}`;
      } catch (e) {
        // Si la table n'existe pas, ignorer
      }
    }

    // Supprimer les items puis la commande
    await prisma.order_items.deleteMany({ where: { orderId } });
    await prisma.orders.delete({ where: { id: orderId } });
  }
  static async getArchivedOrders(
    userId: string,
    page: number = 1,
    limit: number = 10
  ): Promise<OrderArchiveResponse> {
    const offset = (page - 1) * limit;

    const data = await prisma.orders_archive.findMany({
      skip: offset,
      take: limit,
      where: {
        userId
      },
      include: {
        services: true,
        addresses: true
      },
      orderBy: {
        archived_at: 'desc'
      }
    });

    const count = await prisma.orders_archive.count({
      where: {
        userId
      }
    });

    // Transformer les données pour correspondre au type OrderArchive
    const transformedData: OrderArchive[] = data.map(order => {
      // Transformer l'adresse avec une gestion correcte des types null/undefined
      const transformedAddress = order.addresses ? {
        id: order.addresses.id,
        user_id: order.addresses.userId || '',  // Conversion de null en string vide
        name: order.addresses.name || '',
        street: order.addresses.street,
        city: order.addresses.city,
        postal_code: order.addresses.postal_code || '',
        gps_latitude: order.addresses.gps_latitude?.toNumber() || undefined, // Changement ici
        gps_longitude: order.addresses.gps_longitude?.toNumber() || undefined, // Changement ici
        is_default: order.addresses.is_default || false,
        created_at: order.addresses.created_at || new Date(),
        updated_at: order.addresses.updated_at || new Date()
      } : undefined;

      // Transformer le service (ne pas exposer le prix direct, mais le prix calculé)
      const transformedService: Service | undefined = order.services ? {
        id: order.services.id,
        name: order.services.name,
        description: order.services.description || undefined,
        price: 0, // Le prix direct n'est plus utilisé
        createdAt: order.services.created_at || new Date(),
        updatedAt: order.services.updated_at || new Date()
      } : undefined;

      // Calculer le total via la logique centralisée si possible
      // ...existing code...
      return {
        id: order.id,
        userId: order.userId || '',
        service_id: order.service_id || '',
        address_id: order.address_id || '',
        affiliateCode: order.affiliatecode || '',
        status: order.status as OrderStatus,
        isRecurring: order.isrecurring || false,
        recurrenceType: (order.recurrencetype as RecurrenceType) || 'NONE',
        nextRecurrenceDate: order.nextrecurrencedate || null,
        totalAmount: order.totalAmount ? Number(order.totalAmount) : 0, // À ajuster si tu veux recalculer via OrderPricingService
        collectionDate: order.collectiondate || null,
        deliveryDate: order.deliverydate || null,
        createdAt: order.createdAt || new Date(),
        updatedAt: order.updatedat || new Date(),
        service_type_id: order.service_type_id || '',
        archived_at: order.archived_at || new Date(),
        service: transformedService,
        address: transformedAddress,
        paymentStatus: 'PAID' as PaymentStatus,
        paymentMethod: 'CASH' as PaymentMethod
      };
    });

    return {
      data: transformedData,
      pagination: {
        total: count || 0,
        page,
        limit
      }
    };
  }

  static async archiveOldOrders(days: number = 30): Promise<number> {
    try {
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - days);

      const ordersToArchive = await prisma.orders.findMany({
        where: {
          status: 'DELIVERED',
          createdAt: {
            lt: cutoffDate
          }
        }
      });

      if (!ordersToArchive?.length) return 0;

      await prisma.$transaction(async (tx) => {
        // Créer les archives avec une conversion explicite des types
        await tx.orders_archive.createMany({
          data: ordersToArchive.map(order => ({
            id: order.id,
            address_id: order.addressId,
            affiliatecode: order.affiliateCode,
            status: order.status || 'PENDING',
            isrecurring: order.isRecurring || false,
            recurrencetype: order.recurrenceType || 'NONE',
            nextrecurrencedate: order.nextRecurrenceDate,
            totalAmount: order.totalAmount || 0, // Assure une valeur non-null
            collectiondate: order.collectionDate,
            deliverydate: order.deliveryDate,
            createdAt: order.createdAt || new Date(),
            updatedat: order.updatedAt || new Date(),
            service_id: order.serviceId,
            service_type_id: order.service_type_id,
            userId: order.userId,
            archived_at: new Date()
          }))
        });

        await tx.orders.deleteMany({
          where: {
            id: {
              in: ordersToArchive.map(o => o.id)
            }
          }
        });
      });

      return ordersToArchive.length;
    } catch (error) {
      console.error('Error archiving orders:', error);
      throw error;
    }
  }
}
