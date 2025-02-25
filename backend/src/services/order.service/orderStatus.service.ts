import supabase from '../../config/database';
import { Order, OrderStatus, NotificationType } from '../../models/types'; 
import { NotificationService } from '../notification.service';

export class OrderStatusService {
  // Définition des transitions de statut valides
  private static readonly validStatusTransitions: Record<OrderStatus, OrderStatus[]> = {
    'DRAFT': ['PENDING'],      // Pour les commandes flash
    'PENDING': ['COLLECTING'],
    'COLLECTING': ['COLLECTED'],
    'COLLECTED': ['PROCESSING'],
    'PROCESSING': ['READY'],
    'READY': ['DELIVERING'],
    'DELIVERING': ['DELIVERED'],
    'DELIVERED': [],  // Statut final
    'CANCELLED': []   // Statut final
  };

  // Valider la transition de statut
  private static validateStatusTransition(currentStatus: OrderStatus, newStatus: OrderStatus): boolean {
    const validNextStatuses = this.validStatusTransitions[currentStatus];
    return validNextStatuses.includes(newStatus);
  } 

  static async updateOrderStatus(
    orderId: string, 
    newStatus: OrderStatus, 
    userId: string, 
    userRole: string 
  ): Promise<Order> {
    console.log(`Attempting to update order ${orderId} to status ${newStatus}`);

    // 1. Vérifier si la commande existe et obtenir son statut actuel
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .select('*')
      .eq('id', orderId)
      .single();

    if (orderError || !order) {
      console.error('Order not found:', orderError);
      throw new Error('Order not found');
    }

    // 2. Vérifier les autorisations
    const allowedRoles = ['ADMIN', 'SUPER_ADMIN', 'DELIVERY'];
    if (!allowedRoles.includes(userRole)) {
      console.error(`Unauthorized role ${userRole} attempting to update order status`);
      throw new Error('Unauthorized to update order status');
    }

    // 3. Valider la transition de statut
    if (!this.validateStatusTransition(order.status, newStatus)) {
      console.error(`Invalid status transition from ${order.status} to ${newStatus}`);
      throw new Error(`Invalid status transition from ${order.status} to ${newStatus}`);
    }

    // 4. Mettre à jour le statut
    const { data: updatedOrder, error: updateError } = await supabase
      .from('orders')
      .update({
        status: newStatus,
        updatedAt: new Date()
      })
      .eq('id', orderId)
      .select()
      .single();

    if (updateError) {
      console.error('Error updating order status:', updateError);
      throw updateError;
    }

    // 5. Si le statut est "DELIVERED", mettre à jour les statistiques
    if (newStatus === 'DELIVERED' && order.status !== 'DELIVERED') {
      await this.handleDeliveredStatus(orderId, order.userId);
    }

    // 6. Notifier le client du changement de statut
    try {
      await NotificationService.createOrderNotification(
        order.userId,
        orderId,
        NotificationType.ORDER_STATUS_UPDATED,
        { newStatus }
      );
    } catch (notifError) {
      console.error('Error sending notification:', notifError);
      // Ne pas bloquer la mise à jour du statut si la notification échoue
    }

    return updatedOrder;
  }

  private static async handleDeliveredStatus(orderId: string, userId: string): Promise<void> {
    try {
      // Récupérer les détails de la commande pour les statistiques
      const { data: orderDetails, error: orderError } = await supabase
        .from('orders')
        .select('totalAmount')
        .eq('id', orderId)
        .single();

      if (orderError) {
        console.error('Error fetching order details:', orderError);
        return;
      }

      // Ajouter à l'historique des commandes livrées
      const { error: historyError } = await supabase
        .from('delivery_history')
        .insert([{
          order_id: orderId,
          user_id: userId,
          delivery_date: new Date(),
          total_amount: orderDetails.totalAmount,
          created_at: new Date()
        }]);

      if (historyError) {
        console.error('Error adding to delivery history:', historyError);
      }

      // Log de la mise à jour dans les statistiques
      const { error: logError } = await supabase
        .from('order_status_logs')
        .insert([{
          order_id: orderId,
          previous_status: 'DELIVERING',
          new_status: 'DELIVERED',
          updated_by: userId,
          created_at: new Date()
        }]);

      if (logError) {
        console.error('Error adding status log:', logError);
      }
    } catch (error) {
      console.error('Error updating delivery statistics:', error);
    }
  }

  static async deleteOrder(orderId: string, userId: string, userRole: string): Promise<void> {
    const { data: order } = await supabase
      .from('orders')
      .select('*')
      .eq('id', orderId)
      .single();

    if (!order) {
      throw new Error('Order not found');
    }

    if (order.user_id !== userId && !['ADMIN', 'SUPER_ADMIN'].includes(userRole)) {
      throw new Error('Unauthorized to delete order');
    }

    const { error } = await supabase
      .from('orders')
      .delete()
      .eq('id', orderId);

    if (error) throw error;
  }
}