import { Request, Response } from 'express';
import supabase from '../../config/database';
import { OrderStatus } from '../../models/types';

interface FlashOrderData {
  addressId: string;
  notes?: string;
}

export class FlashOrderController {
  static async createFlashOrder(req: Request, res: Response) {
    try {
      console.log('[FlashOrderController] Creating flash order:', req.body);
      const { addressId, notes } = req.body;
      const userId = req.user?.id;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const orderData = {
        userId,
        addressId,
        status: 'DRAFT',
        totalAmount: 0
      };

      const { data: order, error } = await supabase.rpc(
        'create_flash_order',
        {
          order_data: orderData,
          note_text: notes || ''
        }
      );

      if (error) {
        console.error('[FlashOrderController] Error:', error);
        throw error;
      }

      console.log('[FlashOrderController] Order created successfully:', order);
      res.status(201).json({ 
        success: true,
        data: order 
      });

    } catch (error: any) {
      console.error('[FlashOrderController] Error:', error);
      res.status(500).json({
        success: false,
        error: error.message || 'Failed to create flash order'
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
