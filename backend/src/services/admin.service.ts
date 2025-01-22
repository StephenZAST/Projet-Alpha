import supabase from '../config/database';
import { Service, Article, DashboardStatistics, SystemConfig, RewardConfig, DashboardOrder } from '../models/types';
import { v4 as uuidv4 } from 'uuid';
import { NotificationService } from './notification.service';

export class AdminService {
  static async configureCommissions(commissionRate: number, rewardPoints: number): Promise<SystemConfig> {
    const { data, error } = await supabase
      .from('config')
      .update({ commission_rate: commissionRate, reward_points: rewardPoints })
      .eq('id', 1)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async configureRewards(rewardPoints: number, rewardType: string): Promise<RewardConfig> {
    const { data, error } = await supabase
      .from('rewards')
      .update({ reward_points: rewardPoints, reward_type: rewardType })
      .eq('id', 1)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async createService(name: string, price: number, description?: string): Promise<Service> {
    const newService: Service = {
      id: uuidv4(),
      name: name,
      price: price,
      description: description,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    const { data, error } = await supabase
      .from('services')
      .insert([newService])
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  static async createArticle(name: string, basePrice: number, premiumPrice: number, categoryId: string, description?: string): Promise<Article> {
    const newArticle: Article = {
      id: uuidv4(),
      categoryId: categoryId,
      name: name,
      description: description,
      basePrice: basePrice,
      premiumPrice: premiumPrice,
      createdAt: new Date(),
      updatedAt: new Date()
    };

    const { data, error } = await supabase
      .from('articles')
      .insert([newArticle])
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  static async getAllServices(): Promise<Service[]> {
    const { data, error } = await supabase
      .from('services')
      .select('*');

    if (error) throw error;

    return data;
  }

  static async getAllArticles(): Promise<Article[]> {
    const { data, error } = await supabase
      .from('articles')
      .select('*');

    if (error) throw error;

    return data;
  }

  static async updateService(serviceId: string, name: string, price: number, description?: string): Promise<Service> {
    const { data, error } = await supabase
      .from('services')
      .update({ name, price, description, updatedAt: new Date() })
      .eq('id', serviceId)
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  static async updateArticle(articleId: string, name: string, basePrice: number, premiumPrice: number, categoryId: string, description?: string): Promise<Article> {
    const { data, error } = await supabase
      .from('articles')
      .update({ name, basePrice, premiumPrice, description, categoryId, updatedAt: new Date() })
      .eq('id', articleId)
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  static async deleteService(serviceId: string): Promise<void> {
    const { error } = await supabase
      .from('services')
      .delete()
      .eq('id', serviceId);

    if (error) throw error;
  }

  static async deleteArticle(articleId: string): Promise<void> {
    const { error } = await supabase
      .from('articles')
      .delete()
      .eq('id', articleId);

    if (error) throw error;
  }

  static async updateAffiliateStatus(affiliateId: string, status: string, isActive: boolean) {
    // Vérifier si l'affilié existe
    const { data: affiliate, error: checkError } = await supabase
      .from('affiliate_profiles')
      .select('*, user:users(*)')
      .eq('id', affiliateId)
      .single();

    if (checkError || !affiliate) {
      throw new Error('Affiliate not found');
    }

    // Mettre à jour le statut
    const { data, error } = await supabase
      .from('affiliate_profiles')
      .update({
        status,
        is_active: isActive,
        updated_at: new Date()
      })
      .eq('id', affiliateId)
      .select()
      .single();

    if (error) throw error;

    // Notifier l'affilié
    await NotificationService.create(
      affiliate.user_id,
      'ACCOUNT_STATUS',
      'Statut du compte mis à jour',
      `Votre compte affilié est maintenant ${status.toLowerCase()}`,
      { status, isActive }
    );

    return data;
  }

  static async getDashboardStatistics(): Promise<DashboardStatistics> {
    try {
      // 1. Récupérer les commandes avec la bonne colonne 'totalAmount'
      const { data: ordersTotal, error: ordersError } = await supabase
        .from('orders')
        .select('totalAmount, status, createdAt') // Utiliser les bons noms de colonnes
        .eq('status', 'DELIVERED');

      if (ordersError) throw ordersError;

      // 2. Calculer le total des revenus
      const totalRevenue = ordersTotal?.reduce((sum, order) => 
        sum + (order.totalAmount || 0), 0
      ) || 0;

      // 3. Obtenir les commandes récentes avec le bon mapping
      const { data: recentOrders, error: recentError } = await supabase
        .from('orders')
        .select(`
          id,
          totalAmount,
          status,
          createdAt,
          service:services(name),
          user:users(
            id,
            email,
            first_name,
            last_name
          )
        `)
        .order('createdAt', { ascending: false })
        .limit(5);

      if (recentError) throw recentError;

      // Transformer les données des commandes récentes correctement
      const formattedRecentOrders = recentOrders?.map(order => ({
        id: order.id,
        totalAmount: order.totalAmount,
        status: order.status,
        createdAt: order.createdAt,
        service: { name: order.service?.[0]?.name || '' },
        user: order.user && Array.isArray(order.user) && order.user[0] ? {
          id: order.user[0].id,
          email: order.user[0].email,
          firstName: order.user[0].first_name,
          lastName: order.user[0].last_name
        } : null
      }));

      // Reste de la fonction pour obtenir les autres statistiques
      const { data: ordersByStatus, error: statusError } = await supabase
        .from('orders')
        .select('status');

      if (statusError) throw statusError;

      const statusCount = ordersByStatus.reduce((acc: Record<string, number>, order) => {
        acc[order.status] = (acc[order.status] || 0) + 1;
        return acc;
      }, {});

      // 5. Obtenir le nombre total de clients
      const { count: totalCustomers, error: customersError } = await supabase
        .from('users')
        .select('*', { count: 'exact', head: true })
        .eq('role', 'CLIENT');

      if (customersError) throw customersError;

      return {
        totalRevenue,
        totalOrders: ordersTotal?.length || 0,
        totalCustomers: totalCustomers || 0,
        recentOrders: formattedRecentOrders || [],
        ordersByStatus: statusCount
      } as DashboardStatistics;

    } catch (error) {
      console.error('Error fetching dashboard statistics:', error);
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';
      throw new Error(`Failed to fetch dashboard statistics: ${errorMessage}`);
    }
  }

  static async getTotalRevenue(): Promise<number> {
    try {
      // Récupérer les commandes actives
      const { data: activeOrders, error: activeError } = await supabase
        .from('orders')
        .select('totalAmount')
        .eq('status', 'DELIVERED');

      if (activeError) throw activeError;

      // Récupérer les commandes archivées
      const { data: archivedOrders, error: archiveError } = await supabase
        .from('orders_archive')
        .select('totalAmount')
        .eq('status', 'DELIVERED');

      if (archiveError) throw archiveError;

      // Calculer le total des commandes actives et archivées
      const activeTotal = (activeOrders || []).reduce(
        (sum, order) => sum + (order.totalAmount || 0),
        0
      );

      const archivedTotal = (archivedOrders || []).reduce(
        (sum, order) => sum + (order.totalAmount || 0),
        0
      );

      return activeTotal + archivedTotal;
    } catch (error) {
      console.error('Error calculating total revenue:', error);
      throw new Error('Failed to calculate total revenue');
    }
  }

  static async getTotalOrders(): Promise<number> {
    const { count, error } = await supabase
      .from('orders')
      .select('*', { count: 'exact', head: true });

    if (error) throw error;
    return count || 0;
  }

  static async getTotalCustomers(): Promise<number> {
    const { count, error } = await supabase
      .from('users')
      .select('*', { count: 'exact', head: true })
      .eq('role', 'CLIENT');

    if (error) throw error;
    return count || 0;
  }

  static async getRecentOrders(limit: number = 5) {
    const { data, error } = await supabase
      .from('orders')
      .select(`
        *,
        user:users(email, first_name, last_name),
        service:services(name)
      `)
      .order('created_at', { ascending: false })
      .limit(limit);

    if (error) throw error;
    return data;
  }

  static async getRevenueChartData(): Promise<{ labels: string[], data: number[] }> {
    try {
      console.log('[Revenue Chart] Starting data fetch...');
      
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
      console.log('[Revenue Chart] Seven days ago:', sevenDaysAgo.toISOString());
      
      // Récupérer les commandes actives
      console.log('[Revenue Chart] Fetching active orders...');
      const { data: activeOrders, error: activeError } = await supabase
        .from('orders')
        .select('createdAt, totalAmount')
        .gte('createdAt', sevenDaysAgo.toISOString())
        .eq('status', 'DELIVERED')
        .order('createdAt', { ascending: true });

      if (activeError) {
        console.error('[Revenue Chart] Active orders error:', activeError);
        throw activeError;
      }
      console.log('[Revenue Chart] Active orders received:', activeOrders?.length || 0);

      // Récupérer les commandes archivées
      console.log('[Revenue Chart] Fetching archived orders...');
      const { data: archivedOrders, error: archiveError } = await supabase
        .from('orders_archive')
        .select('createdAt, totalAmount')
        .gte('createdAt', sevenDaysAgo.toISOString())
        .eq('status', 'DELIVERED')
        .order('createdAt', { ascending: true });

      if (archiveError) {
        console.error('[Revenue Chart] Archived orders error:', archiveError);
        throw archiveError;
      }
      console.log('[Revenue Chart] Archived orders received:', archivedOrders?.length || 0);

      // Créer un map pour les revenus journaliers
      const dailyRevenue = new Map<string, number>();

      // Initialiser les 7 derniers jours
      for (let i = 6; i >= 0; i--) {
        const date = new Date();
        date.setDate(date.getDate() - i);
        const dateStr = date.toISOString().split('T')[0];
        dailyRevenue.set(dateStr, 0);
      }

      // Traiter les commandes actives
      if (activeOrders?.length) {
        console.log('[Revenue Chart] Processing active orders...');
        activeOrders.forEach(order => {
          try {
            if (order.createdAt && order.totalAmount) {
              const dateStr = new Date(order.createdAt).toISOString().split('T')[0];
              const amount = parseFloat(order.totalAmount.toString());
              if (!isNaN(amount) && dailyRevenue.has(dateStr)) {
                const currentAmount = dailyRevenue.get(dateStr) || 0;
                dailyRevenue.set(dateStr, currentAmount + amount);
                console.log(`[Revenue Chart] Added active order: ${dateStr} = ${amount}`);
              }
            }
          } catch (e) {
            console.error('[Revenue Chart] Error processing active order:', order, e);
          }
        });
      }

      // Traiter les commandes archivées
      if (archivedOrders?.length) {
        console.log('[Revenue Chart] Processing archived orders...');
        archivedOrders.forEach(order => {
          try {
            if (order.createdAt && order.totalAmount) {
              const dateStr = new Date(order.createdAt).toISOString().split('T')[0];
              const amount = parseFloat(order.totalAmount.toString());
              if (!isNaN(amount) && dailyRevenue.has(dateStr)) {
                const currentAmount = dailyRevenue.get(dateStr) || 0;
                dailyRevenue.set(dateStr, currentAmount + amount);
                console.log(`[Revenue Chart] Added archived order: ${dateStr} = ${amount}`);
              }
            }
          } catch (e) {
            console.error('[Revenue Chart] Error processing archived order:', order, e);
          }
        });
      }

      // Préparer les données pour le graphique
      const sortedEntries = Array.from(dailyRevenue.entries())
        .sort((a, b) => a[0].localeCompare(b[0]));

      const result = {
        labels: sortedEntries.map(([date]) => {
          const [, month, day] = date.split('-');
          return `${day}/${month}`;
        }),
        data: sortedEntries.map(([, amount]) => amount),
      };

      console.log('[Revenue Chart] Final result:', result);
      return result;

    } catch (error: any) {
      console.error('[Revenue Chart] Original error:', error);
      throw new Error(`Failed to fetch revenue chart data: ${error.message || 'Unknown error'}`);
    }
  }
}
