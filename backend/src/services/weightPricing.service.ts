import supabase from '../config/database';
import { WeightBasedPricing, OrderWeight, CreateWeightPricingDTO, WeightRecordDTO } from '../models/weightPricing.types';
import { NotificationService } from './notification.service';
import { NotificationType } from '../models/types';

export class WeightPricingService {
  static async createPricing(data: CreateWeightPricingDTO): Promise<WeightBasedPricing> {
    try {
      const { data: pricing, error } = await supabase
        .from('weight_based_pricing')
        .insert([{
          ...data,
          created_at: new Date(),
          updated_at: new Date()
        }])
        .select()
        .single();

      if (error) throw error;
      return pricing;
    } catch (error) {
      console.error('[WeightPricingService] Create pricing error:', error);
      throw error;
    }
  }

  static async recordWeight(data: WeightRecordDTO, verifiedBy: string): Promise<OrderWeight> {
    try {
      const { data: record, error } = await supabase
        .from('order_weights')
        .insert([{
          order_id: data.order_id,
          weight: data.weight,
          verified_by: verifiedBy,
          verified_at: new Date(),
          created_at: new Date(),
          updated_at: new Date()
        }])
        .select()
        .single();

      if (error) throw error;

      // Obtenir les administrateurs
      const { data: admins, error: adminError } = await supabase
        .from('users')
        .select('id')
        .in('role', ['ADMIN', 'SUPER_ADMIN']);

      if (adminError) throw adminError;

      // Envoyer une notification à chaque admin
      const notificationPromises = admins.map(admin => 
        NotificationService.sendNotification(
          admin.id,
          NotificationType.WEIGHT_RECORDED,
          {
            title: 'Nouveau poids enregistré',
            message: `Un poids de ${data.weight}kg a été enregistré pour la commande ${data.order_id}`,
            data: {
              orderId: data.order_id,
              weight: data.weight,
              verifiedBy: verifiedBy
            }
          }
        )
      );

      await Promise.all(notificationPromises);

      return record;
    } catch (error) {
      console.error('[WeightPricingService] Record weight error:', error);
      throw error;
    }
  }

  static async setPrice(data: {
    service_type_id: string;
    min_weight: number;
    max_weight: number;
    price_per_kg: number;
  }) {
    // Vérifier les chevauchements
    const hasOverlap = await this.checkOverlappingRanges(
      data.service_type_id,
      data.min_weight,
      data.max_weight
    );

    if (hasOverlap) {
      throw new Error('Weight ranges cannot overlap with existing ranges');
    }

    // Vérifier le type de service
    const { data: serviceType, error: serviceError } = await supabase
      .from('service_types')
      .select('requires_weight')
      .eq('id', data.service_type_id)
      .single();

    if (serviceError) throw new Error('Error checking service type');
    if (!serviceType.requires_weight) {
      throw new Error('This service type does not support weight-based pricing');
    }

    const { data: pricing, error } = await supabase
      .from('weight_based_pricing')
      .insert([{
        service_type_id: data.service_type_id,
        min_weight: data.min_weight,
        max_weight: data.max_weight,
        price_per_kg: data.price_per_kg,
        created_at: new Date(),
        updated_at: new Date()
      }])
      .select()
      .single();

    if (error) throw error;
    return pricing;
  }

  private static async checkOverlappingRanges(
    serviceTypeId: string,
    minWeight: number,
    maxWeight: number
  ): Promise<boolean> {
    const { data, error } = await supabase
      .from('weight_based_pricing')
      .select('*')
      .eq('service_type_id', serviceTypeId)
      .eq('is_active', true)
      .or(`min_weight.lte.${maxWeight},max_weight.gte.${minWeight}`);

    if (error) throw error;
    return (data || []).length > 0;
  }

  static async calculatePrice(service_type_id: string, weight: number) {
    // Vérifier si le type de service supporte le prix au poids
    const { data: serviceType, error: serviceError } = await supabase
      .from('service_types')
      .select('requires_weight')
      .eq('id', service_type_id)
      .single();

    if (serviceError) throw new Error('Error checking service type');
    if (!serviceType.requires_weight) {
      throw new Error('This service type does not support weight-based pricing');
    }

    // Récupérer le prix approprié
    const { data: pricing, error } = await supabase
      .from('weight_based_pricing')
      .select('price_per_kg')
      .eq('service_type_id', service_type_id)
      .lte('min_weight', weight)
      .gte('max_weight', weight)
      .eq('is_active', true)
      .single();

    if (error) throw error;
    if (!pricing) throw new Error('No pricing found for this weight range');

    return pricing.price_per_kg * weight;
  }

  // Garder la méthode existante pour la rétrocompatibilité
  static async getPricingForService(serviceId: string): Promise<WeightBasedPricing[]> {
    const { data, error } = await supabase
      .from('weight_based_pricing')
      .select('*')
      .eq('service_type_id', serviceId)
      .eq('is_active', true)
      .order('min_weight', { ascending: true });

    if (error) throw error;
    return data;
  }
}
