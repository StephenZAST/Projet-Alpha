import supabase from '../config/database';
import { Order, OrderStatus } from '../models/types';

export class DeliveryService {
  static async getPendingOrders(userId: string): Promise<Order[]> {
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .eq('status', 'PENDING')
      .eq('userId', userId);

    if (error) throw error;

    return data;
  }

  static async getAssignedOrders(userId: string): Promise<Order[]> {
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .eq('status', 'COLLECTING')
      .eq('userId', userId);

    if (error) throw error;

    return data;
  }
  static async getCOLLECTEDOrders(userId: string): Promise<Order[]> {
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .eq('status', 'COLLECTED')
      .eq('userId', userId);

    if (error) throw error;

    return data;
  }
  static async getPROCESSINGOrders(userId: string): Promise<Order[]> {
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .eq('status', 'PROCESSING')
      .eq('userId', userId);

    if (error) throw error;

    return data;
  }
  static async getREADYOrders(userId: string): Promise<Order[]> {
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .eq('status', 'READY')
      .eq('userId', userId);

    if (error) throw error;

    return data;
  }
  static async getDELIVERINGOrders(userId: string): Promise<Order[]> {
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .eq('status', 'DELIVERING')
      .eq('userId', userId);

    if (error) throw error;

    return data;
  }
  static async getDELIVEREDOrders(userId: string): Promise<Order[]> {
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .eq('status', 'DELIVERED')
      .eq('userId', userId);

    if (error) throw error;

    return data;
  }
  static async getCANCELLEDOrders(userId: string): Promise<Order[]> {
    const { data, error } = await supabase
      .from('orders')
      .select('*')
      .eq('status', 'CANCELLED')
      .eq('userId', userId);

    if (error) throw error;

    return data;
  }

  static async updateOrderStatus(orderId: string, status: OrderStatus, userId: string): Promise<Order> {
    // Vérifier si la commande existe et obtenir les détails complets
    const { data: order, error: fetchError } = await supabase
      .from('orders')
      .select(`
        *,
        service:services(*),
        address:addresses(*)
      `)
      .eq('id', orderId)
      .single();

    if (fetchError || !order) {
      console.error('Error fetching order:', fetchError);
      throw new Error('Order not found');
    }

    // Vérifier si l'utilisateur est autorisé à mettre à jour la commande
    // Plus besoin de vérifier le rôle car c'est déjà fait par le middleware
    const { data, error } = await supabase
      .from('orders')
      .update({ 
        status,
        updated_at: new Date().toISOString()
      })
      .eq('id', orderId)
      .select(`
        *,
        service:services(*),
        address:addresses(*)
      `)
      .single();

    if (error) {
      console.error('Error updating order status:', error);
      throw error;
    }

    return data;
  }
}
