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
      console.log('[FlashOrderController] Starting complete flash order...');
      console.log('[FlashOrderController] Order ID:', req.params.orderId);
      console.log('[FlashOrderController] Payload:', JSON.stringify(req.body, null, 2));

      // Vérifier si la commande existe et est en DRAFT
      const { data: existingOrder, error: checkError } = await supabase
        .from('orders')
        .select('*')
        .eq('id', req.params.orderId)
        .eq('status', 'DRAFT')
        .single();

      if (checkError) {
        console.error('[FlashOrderController] Error checking order:', checkError);
        throw checkError;
      }

      if (!existingOrder) {
        console.error('[FlashOrderController] Order not found or not in DRAFT status');
        return res.status(404).json({
          error: 'Order not found or not in DRAFT status'
        });
      }

      console.log('[FlashOrderController] Existing order found:', existingOrder);

      // Appeler la procédure stockée
      console.log('[FlashOrderController] Calling stored procedure...');
      const { data: result, error } = await supabase.rpc(
        'complete_flash_order',
        {
          p_order_id: req.params.orderId,
          p_service_id: req.body.serviceId,
          p_items: req.body.items,
          p_collection_date: req.body.collectionDate,
          p_delivery_date: req.body.deliveryDate
        }
      );

      if (error) {
        console.error('[FlashOrderController] Stored procedure error:', error);
        throw error;
      }

      console.log('[FlashOrderController] Stored procedure result:', result);

      // Vérifier que le résultat est bien formaté
      if (!result || !result.data || !result.data.order) {
        console.error('[FlashOrderController] Invalid response format:', result);
        throw new Error('Invalid response format from stored procedure');
      }

      console.log('[FlashOrderController] Successfully completed flash order');
      res.json(result);

    } catch (error: any) {
      console.error('[FlashOrderController] Error details:', {
        message: error.message,
        code: error.code,
        hint: error.hint,
        details: error.details
      });
      
      res.status(500).json({
        error: error.message,
        details: process.env.NODE_ENV === 'development' ? {
          code: error.code,
          hint: error.hint,
          details: error.details
        } : undefined
      });
    }
  }
}
