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
        deliveryDate
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

      // Mise à jour de la commande avec transaction
      const updatedOrder = await prisma.$transaction(async (tx) => {
        // 1. Mise à jour de la commande
        const order = await tx.orders.update({
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

        // 2. Création des items
        if (items?.length > 0) {
            interface OrderItemCreate {
            orderId: string;
            articleId: string;
            serviceId: string;
            quantity: number;
            unitPrice: number;
            isPremium?: boolean;
            createdAt: Date;
            updatedAt: Date;
            }

            await tx.order_items.createMany({
            data: items.map((item: OrderItem): OrderItemCreate => ({
              orderId,
              articleId: item.articleId,
              serviceId,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              isPremium: item.isPremium,
              createdAt: new Date(),
              updatedAt: new Date()
            }))
            });
        }

        // 3. Calcul et mise à jour du total
        interface SummableItem {
          quantity: number;
          unitPrice: number;
        }

        const total: number = items.reduce((sum: number, item: SummableItem): number => 
          sum + (item.quantity * item.unitPrice), 
          0
        );

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
            order_metadata: true
          }
        });
      });

      res.json({
        data: updatedOrder,
        message: 'Flash order completed successfully'
      });

    } catch (error: any) {
      console.error('[FlashOrderController] Error completing flash order:', error);
      res.status(500).json({ error: error.message });
    }
  }
}
