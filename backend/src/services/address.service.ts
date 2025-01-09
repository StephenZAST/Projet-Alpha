import supabase from '../config/database';
import { Address } from '../models/types';

export class AddressService {
  static async createAddress(
    userId: string, 
    name: string,
    street: string, 
    city: string, 
    postalCode: string,
    gpsLatitude?: number, 
    gpsLongitude?: number,
    isDefault: boolean = false
  ): Promise<Address> {
    try {
      const { data, error } = await supabase
        .from('addresses')
        .insert([{ 
          user_id: userId,
          name,
          street, 
          city, 
          postal_code: postalCode, 
          gps_latitude: gpsLatitude, 
          gps_longitude: gpsLongitude, 
          is_default: isDefault,
          created_at: new Date(),
          updated_at: new Date()
        }])
        .select()
        .single();

      if (error) {
        console.error('Supabase error:', error);
        throw error;
      }

      return data;
    } catch (error) {
      console.error('Address creation error:', error);
      throw error;
    }
  }

  static async getAllAddresses(userId: string): Promise<Address[]> {
    const { data, error } = await supabase
      .from('addresses')
      .select('*')
      .eq('user_id', userId);

    if (error) throw error;

    return data;
  }

  static async updateAddress(addressId: string, userId: string, street: string, city: string, isDefault: boolean, postalCode?: string, gpsLatitude?: number, gpsLongitude?: number): Promise<Address> {
    const { data, error } = await supabase
      .from('addresses')
      .update({ street, city, postal_code: postalCode, gps_latitude: gpsLatitude, gps_longitude: gpsLongitude, is_default: isDefault, updated_at: new Date() })
      .eq('id', addressId)
      .eq('user_id', userId)
      .select()
      .single();

    if (error) throw error;

    return data;
  }

  static async deleteAddress(addressId: string, userId: string): Promise<void> {
    const { error } = await supabase
      .from('addresses')
      .delete()
      .eq('id', addressId)
      .eq('user_id', userId);

    if (error) throw error;
  }
}
