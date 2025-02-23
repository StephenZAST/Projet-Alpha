import { Request, Response } from 'express';
import supabase from '../../config/database';
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

      const noteText = notes || note; // Accepter les deux formats
      console.log('[FlashOrderController] Using note:', noteText);

      console.log('[FlashOrderController] Creating order for user:', userId);

      // Créer la commande avec les métadonnées
      const { data, error } = await supabase.rpc('create_flash_order_with_metadata', {
        order_data: {
          userId: userId,
          addressId: addressId,
          status: 'DRAFT',
          totalAmount: 0,
          createdAt: new Date(),
          updatedAt: new Date()
        },
        metadata: {
          is_flash_order: true,
          note: noteText // Ajouter la note dans les métadonnées aussi
        },
        note_text: noteText
      });

      if (error) {
        console.error('[FlashOrderController] Error:', error);
        return res.status(500).json({ error: error.message });
      }

      if (!data) {
        console.error('[FlashOrderController] No data returned');
        return res.status(500).json({ error: 'Failed to create order' });
      }

      console.log('[FlashOrderController] Order created successfully:', data);
      res.json({ data: data });

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
      console.log('[FlashOrderController] Completing order:', orderId);

      // 1. Vérifier d'abord que la commande existe et est une commande flash
      const { data: flashOrder, error: checkError } = await supabase
        .from('orders')
        .select(`
          *,
          metadata:order_metadata!inner(*)
        `)
        .eq('id', orderId)
        .eq('order_metadata.is_flash_order', true)
        .single();

      if (checkError || !flashOrder) {
        console.error('[FlashOrderController] Order not found or not a flash order:', checkError);
        return res.status(404).json({ error: 'Flash order not found' });
      }

      if (flashOrder.status !== 'DRAFT') {
        return res.status(400).json({ 
          error: `Cannot complete order in status: ${flashOrder.status}. Order must be in DRAFT status.`
        });
      }

      const {
        serviceId,
        items,
        serviceTypeId,
        collectionDate,
        deliveryDate
      } = req.body;

      // 2. Mettre à jour la commande
      const { data: updatedOrder, error: updateError } = await supabase
        .from('orders')
        .update({
          serviceId,
          service_type_id: serviceTypeId,
          collectionDate,
          deliveryDate,
          status: 'COLLECTING',
          updatedAt: new Date()
        })
        .eq('id', orderId)
        .select()
        .single();

      if (updateError) {
        console.error('[FlashOrderController] Error updating order:', updateError);
        throw updateError;
      }

      // 3. Ajouter les items
      if (items && items.length > 0) {
        const orderItems = items.map((item: OrderItem) => ({
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

        if (itemsError) {
          console.error('[FlashOrderController] Error inserting items:', itemsError);
          throw itemsError;
        }
      }

      // 4. Calculer le total avec typage explicite
      const total = items.reduce((sum: number, item: OrderItem) => 
        sum + (item.quantity * item.unitPrice), 
        0
      );
      
      // 5. Mettre à jour le total
      const { error: totalError } = await supabase
        .from('orders')
        .update({ totalAmount: total })
        .eq('id', orderId);

      if (totalError) {
        console.error('[FlashOrderController] Error updating total:', totalError);
        throw totalError;
      }

      // 6. Récupérer la commande finale avec toutes ses relations
      const { data: completedOrder, error: fetchError } = await supabase
        .from('orders')
        .select(`
          *,
          user:users(first_name, last_name, phone, email),
          address:addresses(*),
          items:order_items(*),
          metadata:order_metadata(*)
        `)
        .eq('id', orderId)
        .single();

      if (fetchError) throw fetchError;

      res.json({ 
        data: completedOrder,
        message: 'Flash order completed successfully'
      });

    } catch (error: any) {
      console.error('[FlashOrderController] Error completing flash order:', error);
      res.status(500).json({ error: error.message });
    }
  }

  static async getDraftFlashOrders(req: Request, res: Response) {
    try {
      console.log('[FlashOrderController] Fetching draft flash orders');
      
      const { data: orders, error } = await supabase
        .from('orders')
        .select(`
          *,
          metadata:order_metadata!inner(*),
          user:users(
            first_name,
            last_name,
            phone
          ),
          address:addresses(*)
        `)
        .eq('status', 'DRAFT')
        .eq('order_metadata.is_flash_order', true)
        .order('createdAt', { ascending: false }); // Changé de created_at à createdAt

      if (error) {
        console.error('[FlashOrderController] Database error:', error);
        throw error;
      }

      console.log('[FlashOrderController] Found draft orders:', orders?.length);
      res.json({ data: orders });
    } catch (error: any) {
      console.error('[FlashOrderController] Error:', error);
      res.status(500).json({ error: error.message });
    }
  }
}
