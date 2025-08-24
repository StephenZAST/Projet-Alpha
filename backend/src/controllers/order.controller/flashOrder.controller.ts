import { Request, Response } from 'express';
import prisma from '../../config/prisma';
import { OrderStatus } from '../../models/types';

interface FlashOrderData {
  addressId: string;
  notes?: string;
  note?: string;  // Ajouter cette propriété pour accepter les deux formats
}

interface OrderItem {
  articleId: string;
  quantity: number;
  unitPrice: number;
  isPremium?: boolean;
}

export class FlashOrderController {
  static async createFlashOrder(req: Request, res: Response) {
    console.log('[FlashOrderController] Creating flash order with data:', req.body);
    try {
      const { addressId, notes, note } = req.body as FlashOrderData;
      const userId = req.user?.id;
      
      if (!userId) {
        console.error('[FlashOrderController] No userId found in request');
        return res.status(401).json({ error: 'Unauthorized - User ID required' });
      }

      const noteText = notes || note;

      // Créer la commande avec les métadonnées
      const defaultServiceTypeId = await prisma.service_types.findFirst({
        where: {
          is_default: true
        },
        select: {
          id: true
        }
      });

      if (!defaultServiceTypeId) {
        throw new Error('No default service type found');
      }

      const order = await prisma.orders.create({
        data: {
          userId,
          addressId,
          status: 'DRAFT',
          totalAmount: 0,
          createdAt: new Date(),
          updatedAt: new Date(),
          service_type_id: defaultServiceTypeId.id, // Utiliser l'ID du service type par défaut
          order_metadata: {
            create: {
              is_flash_order: true,
              metadata: { note: noteText }
            }
          },
          order_notes: {
            create: {
              note: noteText
            }
          }
        }
      });

      console.log('[FlashOrderController] Order created successfully:', order);
      res.json({ data: order });

    } catch (error: any) {
      console.error('[FlashOrderController] Unexpected error:', error);
      res.status(500).json({
        error: 'Failed to create flash order',
        details: process.env.NODE_ENV === 'development' ? error.message : undefined
      });
    }
  }

  static async getAllPendingOrders(req: Request, res: Response) {
    try {
      const orders = await prisma.orders.findMany({
        where: {
          status: 'PENDING'
        },
        include: {
          user: {
            select: {
              first_name: true,
              last_name: true,
              phone: true
            }
          },
          address: true
        },
        orderBy: {
          createdAt: 'desc'
        }
      });

      res.json({ data: orders });
    } catch (error: any) {
      console.error('[FlashOrderController] Error fetching pending orders:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async completeFlashOrder(req: Request, res: Response) {
    try {
      const { orderId } = req.params;
      const {
        serviceId,
        items,
        serviceTypeId,
        collectionDate,
        deliveryDate,
        note // Ajout du champ note dans le payload
      } = req.body;

      // Vérifier que la commande existe et est une commande flash
      const flashOrder = await prisma.orders.findFirst({
        where: {
          id: orderId,
          order_metadata: {
            is_flash_order: true
          }
        },
        include: {
          order_metadata: true
        }
      });

      if (!flashOrder) {
        return res.status(404).json({ error: 'Flash order not found' });
      }

      if (flashOrder.status !== 'DRAFT') {
        return res.status(400).json({
          error: `Cannot complete order in status: ${flashOrder.status}. Order must be in DRAFT status.`
        });
      }

      // Transaction : mise à jour, calcul des prix, création des items, calcul du total
      const updatedOrder = await prisma.$transaction(async (tx) => {
        // 1. Mise à jour de la commande
        await tx.orders.update({
          where: { id: orderId },
          data: {
            serviceId,
            service_type_id: serviceTypeId,
            collectionDate,
            deliveryDate,
            status: 'COLLECTING',
            updatedAt: new Date()
          }
        });

        // 1bis. Mise à jour ou création de la note si fournie
        if (typeof note === 'string' && note.trim().length > 0) {
          const existingNote = await tx.order_notes.findFirst({
            where: { order_id: orderId }
          });
          if (existingNote) {
            await tx.order_notes.update({
              where: { id: existingNote.id },
              data: { note, updated_at: new Date() }
            });
          } else {
            await tx.order_notes.create({
              data: {
                order_id: orderId,
                note,
                created_at: new Date(),
                updated_at: new Date()
              }
            });
          }
        }

        // 2. Calcul automatique du unitPrice et création des items
        let mappedItems: any[] = [];
        if (items?.length > 0) {
          // Récupérer tous les couples de prix pour les articles concernés
          const couplePrices = await tx.article_service_prices.findMany({
            where: {
              article_id: { in: items.map((item: OrderItem) => item.articleId) },
              service_type_id: serviceTypeId,
              service_id: serviceId
            }
          });
          const couplePriceMap = new Map<string, { base_price: number; premium_price: number }>(
            couplePrices
              .filter((c: any) => c.article_id)
              .map((c: any) => [c.article_id as string, { base_price: Number(c.base_price), premium_price: Number(c.premium_price) }])
          );

          mappedItems = items.map((item: OrderItem) => {
            const couple = couplePriceMap.get(item.articleId);
            const unitPrice = couple
              ? (item.isPremium ? couple.premium_price : couple.base_price)
              : 1; // fallback si pas trouvé
            return {
              orderId,
              articleId: item.articleId,
              serviceId,
              quantity: item.quantity,
              unitPrice,
              isPremium: item.isPremium,
              createdAt: new Date(),
              updatedAt: new Date()
            };
          });
          await tx.order_items.createMany({ data: mappedItems });
        }

        // 3. Calcul du total à partir des items insérés
        const total: number = mappedItems.reduce((sum: number, item: any): number =>
          sum + (item.quantity * item.unitPrice),
          0
        );

        // 4. Mise à jour du total et retour de la commande complète
        return await tx.orders.update({
          where: { id: orderId },
          data: { totalAmount: total },
          include: {
            user: {
              select: {
                first_name: true,
                last_name: true,
                phone: true,
                email: true
              }
            },
            address: true,
            order_items: {
              include: {
                article: true
              }
            },
            order_metadata: true,
            order_notes: true
          }
        });
      });

      res.json({
        data: updatedOrder,
        total: updatedOrder.totalAmount,
        message: 'Flash order completed successfully'
      });

    } catch (error: any) {
      console.error('[FlashOrderController] Error completing flash order:', error);
      res.status(500).json({ error: error.message });
    }
  }
}
