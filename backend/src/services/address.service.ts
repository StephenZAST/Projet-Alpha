import supabase from '../config/database';
import { Address } from '../models/types';

export class AddressService {
  static async getAddressById(addressId: string): Promise<Address | null> {
    try {
      console.log('Getting address by ID:', addressId);
      const { data, error } = await supabase
        .from('addresses')
        .select('*')
        .eq('id', addressId)
        .single();

      if (error) {
        console.error('Error getting address:', error);
        throw error;
      }

      console.log('Found address:', data);
      return data;
    } catch (error) {
      console.error('Get address by ID error:', error);
      throw error;
    }
  }

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

  static async updateAddress(
    addressId: string,
    userId: string,
    name: string,
    street: string,
    city: string,
    postalCode: string,
    gpsLatitude?: number,
    gpsLongitude?: number,
    isDefault: boolean = false
  ): Promise<Address> {
    console.log('Updating address with data:', {
      addressId,
      userId,
      name,
      street,
      city,
      postalCode,
      gpsLatitude,
      gpsLongitude,
      isDefault
    });

    // Vérifier d'abord si l'adresse existe et appartient à l'utilisateur
    const { data: existingAddress, error: checkError } = await supabase
      .from('addresses')
      .select('*')
      .eq('id', addressId)
      .eq('user_id', userId)
      .single();

    if (checkError || !existingAddress) {
      throw new Error('Address not found or unauthorized');
    }

    const { data, error } = await supabase
      .from('addresses')
      .update({
        name,
        street,
        city,
        postal_code: postalCode,
        gps_latitude: gpsLatitude,
        gps_longitude: gpsLongitude,
        is_default: isDefault,
        updated_at: new Date()
      })
      .eq('id', addressId)
      .eq('user_id', userId)  // S'assurer que l'utilisateur possède l'adresse
      .select()
      .single();

    if (error) {
      console.error('Update address error:', error);
      throw error;
    }

    console.log('Address updated successfully:', data);
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
