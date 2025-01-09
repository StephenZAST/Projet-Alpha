import { Request, Response } from 'express';
import { AddressService } from '../services/address.service';
import { Address } from '../models/types';

export class AddressController {
  static async createAddress(req: Request, res: Response) {
    try {
      console.log('Creating address with data:', req.body);
      console.log('User:', req.user);

      if (!req.user?.id) {
        return res.status(401).json({ error: 'User not authenticated' });
      }

      const { 
        name,
        street, 
        city, 
        postal_code, 
        gps_latitude, 
        gps_longitude, 
        is_default 
      } = req.body;

      // Validation
      if (!name || !street || !city || !postal_code) {
        return res.status(400).json({ 
          error: 'Missing required fields: name, street, city, postal_code' 
        });
      }

      const address = await AddressService.createAddress(
        req.user.id,
        name,
        street,
        city,
        postal_code,
        gps_latitude,
        gps_longitude,
        is_default
      );

      res.json({ data: address });
    } catch (error: unknown) {
      console.error('Error in createAddress controller:', error);
      res.status(500).json({ 
        error: 'Failed to create address',
        details: error instanceof Error ? error.message : String(error)
      });
    }
  }
  static async getAllAddresses(req: Request, res: Response) {
    try {
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const addresses = await AddressService.getAllAddresses(userId);
      res.json({ data: addresses });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async updateAddress(req: Request, res: Response) {
    try {
      const addressId = req.params.addressId;
      const { street, city, postalCode, gpsLatitude, gpsLongitude, isDefault } = req.body;
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const address = await AddressService.updateAddress(addressId, userId, street, city, isDefault, postalCode, gpsLatitude, gpsLongitude);
      res.json({ data: address });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async deleteAddress(req: Request, res: Response) {
    try {
      const addressId = req.params.addressId;
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      await AddressService.deleteAddress(addressId, userId);
      res.json({ message: 'Address deleted successfully' });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}
