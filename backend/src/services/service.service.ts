import supabase from '../config/database';
import { Service } from '../models/types';

export class ServiceService {
  static async createService(name: string, price: number, description?: string): Promise<Service> {
    const { data, error } = await supabase
      .from('services')
      .insert([{ name, price, description }])
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  static async getAllServices(): Promise<Service[]> {
    try {
      const { data, error } = await supabase
        .from('services')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      return data || [];
    } catch (error) {
      console.error('Error in getAllServices:', error);
      throw error;
    }
  }

  static async updateService(serviceId: string, name: string, price: number, description?: string): Promise<Service> {
    const { data, error } = await supabase
      .from('services')
      .update({ name, price, description, updated_at: new Date() })
      .eq('id', serviceId)
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
}
 