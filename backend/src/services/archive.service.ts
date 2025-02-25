import supabase from '../config/database';
import { OrderArchiveResponse, OrderArchive } from '../models/types'; 

export class ArchiveService {
  static async getArchivedOrders(
    userId: string,
    page: number = 1,
    limit: number = 10
  ): Promise<OrderArchiveResponse> {
    const offset = (page - 1) * limit;

    const { data, error, count } = await supabase
      .from('orders_archive')
      .select('*, service:services(*), address:addresses(*)', { count: 'exact' })
      .eq('userId', userId)
      .order('archived_at', { ascending: false })
      .range(offset, offset + limit - 1);

    if (error) throw error;

    return {
      data: data || [],
      pagination: {
        total: count || 0,
        page,
        limit
      }
    };
  }  

  static async archiveOldOrders(days: number = 30): Promise<number> {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - days);

    // Modification du nom de la colonne created_at -> createdat
    const { data: ordersToArchive, error: selectError } = await supabase
      .from('orders')
      .select('*')
      .eq('status', 'DELIVERED')
      .lt('createdAt', cutoffDate.toISOString());  // Changé ici

    if (selectError) {
      console.error('Select Error:', selectError);
      throw selectError;
    }

    if (!ordersToArchive?.length) return 0;

    // Adapter les données pour correspondre au schéma de la table orders_archive
    const archiveData = ordersToArchive.map(order => ({
      ...order,
      archived_at: new Date(),
      // S'assurer que les noms de colonnes correspondent exactement
      userid: order.user_id || order.userid,
      affiliatecode: order.affiliateCode || order.affiliatecode,
      isrecurring: order.isRecurring || order.isrecurring,
      recurrencetype: order.recurrenceType || order.recurrencetype,
      totalamount: order.totalAmount || order.totalamount,
      createdAt: order.createdAt,
      updatedat: order.updatedat
    }));

    const { error: insertError } = await supabase
      .from('orders_archive')
      .insert(archiveData);

    if (insertError) {
      console.error('Insert Error:', insertError);
      throw insertError;
    }

    // Suppression des ordres archivés
    const { error: deleteError } = await supabase
      .from('orders')
      .delete()
      .in('id', ordersToArchive.map(o => o.id));

    if (deleteError) {
      console.error('Delete Error:', deleteError);
      throw deleteError;
    }

    return ordersToArchive.length;
  }
}
