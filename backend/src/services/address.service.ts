import { PrismaClient } from '@prisma/client';
import { Address } from '../models/types';

const prisma = new PrismaClient();

export class AddressService {
  static async getAddressById(addressId: string): Promise<Address | null> {
    try {
      console.log('Getting address by ID:', addressId);
      const address = await prisma.addresses.findUnique({
        where: { id: addressId }
      });

      console.log('Found address:', address);
      if (!address) return null;
      return {
        id: address.id,
        user_id: address.user_id || '',
        name: address.name || '',
        street: address.street,
        city: address.city,
        postal_code: address.postal_code || '',
        gps_latitude: address.gps_latitude ? Number(address.gps_latitude) : undefined,
        gps_longitude: address.gps_longitude ? Number(address.gps_longitude) : undefined,
        is_default: address.is_default || false,
        created_at: address.created_at || new Date(),
        updated_at: address.updated_at || new Date()
      };
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
      const address = await prisma.addresses.create({
        data: {
          user_id: userId,
          name,
          street,
          city,
          postal_code: postalCode,
          gps_latitude: gpsLatitude ? Number(gpsLatitude) : null,
          gps_longitude: gpsLongitude ? Number(gpsLongitude) : null,
          is_default: isDefault,
          created_at: new Date(),
          updated_at: new Date()
        }
      });

      return {
        id: address.id,
        user_id: address.user_id || '',
        name: address.name || '',
        street: address.street,
        city: address.city,
        postal_code: address.postal_code || '',
        gps_latitude: address.gps_latitude ? Number(address.gps_latitude) : undefined,
        gps_longitude: address.gps_longitude ? Number(address.gps_longitude) : undefined,
        is_default: address.is_default || false,
        created_at: address.created_at || new Date(),
        updated_at: address.updated_at || new Date()
      };
    } catch (error) {
      console.error('Address creation error:', error);
      throw error;
    }
  }

  static async getAllAddresses(userId: string): Promise<Address[]> {
    try {
      const addresses = await prisma.addresses.findMany({
        where: { user_id: userId }
      });

      return addresses.map(address => ({
        id: address.id,
        user_id: address.user_id || '',
        name: address.name || '',
        street: address.street,
        city: address.city,
        postal_code: address.postal_code || '',
        gps_latitude: address.gps_latitude ? Number(address.gps_latitude) : undefined,
        gps_longitude: address.gps_longitude ? Number(address.gps_longitude) : undefined,
        is_default: address.is_default || false,
        created_at: address.created_at || new Date(),
        updated_at: address.updated_at || new Date()
      }));
    } catch (error) {
      console.error('Get all addresses error:', error);
      throw error;
    }
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
    const existingAddress = await prisma.addresses.findFirst({
      where: {
        id: addressId,
        user_id: userId
      }
    });

    if (!existingAddress) {
      throw new Error('Address not found or unauthorized');
    }

    const updatedAddress = await prisma.addresses.update({
      where: {
        id: addressId
      },
      data: {
        name,
        street,
        city,
        postal_code: postalCode,
        gps_latitude: gpsLatitude ? Number(gpsLatitude) : null,
        gps_longitude: gpsLongitude ? Number(gpsLongitude) : null,
        is_default: isDefault,
        updated_at: new Date()
      }
    });

    console.log('Address updated successfully:', updatedAddress);
    return {
      id: updatedAddress.id,
      user_id: updatedAddress.user_id || '',
      name: updatedAddress.name || '',
      street: updatedAddress.street,
      city: updatedAddress.city,
      postal_code: updatedAddress.postal_code || '',
      gps_latitude: updatedAddress.gps_latitude ? Number(updatedAddress.gps_latitude) : undefined,
      gps_longitude: updatedAddress.gps_longitude ? Number(updatedAddress.gps_longitude) : undefined,
      is_default: updatedAddress.is_default || false,
      created_at: updatedAddress.created_at || new Date(),
      updated_at: updatedAddress.updated_at || new Date()
    };
  }

  static async deleteAddress(addressId: string, userId: string): Promise<void> {
    try {
      await prisma.addresses.deleteMany({
        where: {
          id: addressId,
          user_id: userId
        }
      });
    } catch (error) {
      console.error('Delete address error:', error);
      throw error;
    }
  }
}
