import { Request, Response } from 'express';
import supabase from '../../config/database';
import { OrderStatus } from '../../models/types';

interface FlashOrderData {
  addressId: string;
  notes?: string;
}

export class FlashOrderController {
  static async createFlashOrder(req: Request, res: Response) {
    console.log('[FlashOrderController] Starting flash order creation');
    try {
      const { addressId, notes } = req.body as FlashOrderData;
      const userId = req.user?.id;
      
      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      // 1. Créer la commande avec uniquement les informations essentielles
      const orderData = {
        userId,
        addressId,
        status: 'PENDING' as OrderStatus, // Utiliser PENDING au lieu de DRAFT
        createdAt: new Date(),
        updatedAt: new Date(),
        totalAmount: 0 // Sera mis à jour plus tard
      };

      // Créer la commande avec le trigger qui insérera la note
      let { data: order, error } = await supabase.rpc('create_flash_order', {
        order_data: orderData,
        note_text: notes || ''
      });

      if (error) {
        console.error('[FlashOrderController] Error creating flash order:', error);
        throw error;
      }

      if (!order) {
        console.error('[FlashOrderController] create_flash_order RPC did not return order data');
        throw new Error('Failed to create flash order. Please try again.');
      }

      console.log('[FlashOrderController] Flash order created:', order.id);

      // 2. Envoyer la réponse
      res.json({
        data: {
          order,
          message: 'Flash order created successfully. We will process your order soon.'
        }
      });

    } catch (error: any) {
      console.error('[FlashOrderController] Error:', error);
      res.status(500).json({
        error: error.message || 'Error creating flash order',
        details: process.env.NODE_ENV === 'development' ? error : undefined
      });
    }
  }

  static async getAllPendingOrders(req: Request, res: Response) {
    try {
      const { data: orders, error } = await supabase
        .from('orders')
        .select(`
          *,
          user:users(
            first_name,
            last_name,
            phone
          ),
          address:addresses(*)
        `)
        .eq('status', 'PENDING')
        .order('createdAt', { ascending: false });

      if (error) throw error;

      res.json({ data: orders });
    } catch (error: any) {
      console.error('[FlashOrderController] Error fetching pending orders:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async completeFlashOrder(req: Request, res: Response) {
    try {
      const { orderId } = req.params;
      interface OrderItem {
        articleId: string;
        quantity: number;
        unitPrice: number;
      }

      const {
        serviceId,
        items,
        serviceTypeId,
        collectionDate,
        deliveryDate
      }: {
        serviceId: string;
        items: OrderItem[];
        serviceTypeId?: string;
        collectionDate?: Date;
        deliveryDate?: Date;
      } = req.body;

      // 1. Mettre à jour la commande
      const { data: order, error: updateError } = await supabase
        .from('orders')
        .update({
          serviceId,
          service_type_id: serviceTypeId,
          collectionDate,
          deliveryDate,
          status: 'COLLECTING' as OrderStatus, // Passer à COLLECTING une fois les détails ajoutés
          updatedAt: new Date()
        })
        .eq('id', orderId)
        .eq('status', 'PENDING')
        .select()
        .single();

      if (updateError) throw updateError;
      if (!order) {
        return res.status(404).json({ error: 'Flash order not found' });
      }

      // 2. Ajouter les items
      if (items && items.length > 0) {
        const orderItems = items.map(item => ({
          orderId,
          articleId: item.articleId,
          serviceId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          createdAt: new Date(),
          updatedAt: new Date()
        }));

        const { error: itemsError } = await supabase
          .from('order_items')
          .insert(orderItems);

        if (itemsError) throw itemsError;
      }

      // 3. Récupérer la commande mise à jour avec tous les détails
      const { data: completedOrder, error: fetchError } = await supabase
        .from('orders')
        .select(`
          *,
          user:users(
            first_name,
            last_name,
            phone
          ),
          address:addresses(*),
          items:order_items(*)
        `)
        .eq('id', orderId)
        .single();

      if (fetchError) throw fetchError;

      res.json({ 
        data: completedOrder,
        message: 'Flash order updated successfully'
      });

    } catch (error: any) {
      console.error('[FlashOrderController] Error completing flash order:', error);
      res.status(500).json({ error: error.message });
    }
  }
}
