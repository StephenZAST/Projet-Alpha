import supabase from '../config/database';
import { Service, Article, ArticleCategory } from '../models/types';
import { v4 as uuidv4 } from 'uuid';
import { NotificationService } from './notification.service';

export class AdminService {
  static async configureCommissions(commissionRate: number, rewardPoints: number): Promise<void> {
    const { error } = await supabase
      .from('config')
      .update({ commission_rate: commissionRate, reward_points: rewardPoints })
      .eq('id', 1);

    if (error) throw error;
  }

  static async configureRewards(rewardPoints: number, rewardType: string): Promise<void> {
    const { error } = await supabase
      .from('rewards')
      .update({ reward_points: rewardPoints, reward_type: rewardType })
      .eq('id', 1);

    if (error) throw error;
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
}
