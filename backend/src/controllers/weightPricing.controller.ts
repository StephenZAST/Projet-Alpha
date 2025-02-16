import { Request, Response } from 'express';
import supabase from '../config/database';
import { handleError } from '../utils/errorHandler';

export class WeightPricingController {
  static async setWeightPrice(req: Request, res: Response) {
    try {
      const { service_type_id, min_weight, max_weight, price_per_kg } = req.body;

      // Vérification des données requises
      if (!service_type_id || !min_weight || !max_weight || !price_per_kg) {
        return res.status(400).json({
          success: false,
          error: { message: 'All fields are required' }
        });
      }

      const { data, error } = await supabase
        .from('weight_based_pricing')
        .insert([{
          service_type_id,
          min_weight,
          max_weight,
          price_per_kg,
          is_active: true,
          created_at: new Date(),
          updated_at: new Date()
        }])
        .select()
        .single(); 

      if (error) throw error;
      res.status(201).json({ success: true, data });
    } catch (error: any) {
      handleError(res, error);
    }
  }

  static async calculatePrice(req: Request, res: Response) {
    try {
      const { service_type_id, weight } = req.body;

      if (!service_type_id || !weight) {
        return res.status(400).json({
          success: false,
          error: { 
            message: 'service_type_id and weight are required',
            code: 'VALIDATION_ERROR'
          }
        });
      }

      const { data: price, error } = await supabase
        .rpc('calculate_weight_price', {
          p_service_type_id: service_type_id,
          p_weight: weight
        });

      if (error) throw error;
      
      res.json({
        success: true,
        data: { price }
      });
    } catch (error: any) {
      handleError(res, error);
    }
  }

  static async getPricingForService(req: Request, res: Response) {
    try {
      const { service_type_id } = req.params;

      const { data, error } = await supabase
        .from('weight_based_pricing')
        .select('*')
        .eq('service_type_id', service_type_id)
        .eq('is_active', true)
        .order('min_weight', { ascending: true });

      if (error) throw error;
      
      res.json({
        success: true,
        data
      });
    } catch (error: any) {
      handleError(res, error);
    }
  }
}
