import { Request, Response } from 'express';
import { AddressService } from '../services/address.service';
import { Address } from '../models/types';

export class AddressController {
  static async createAddress(req: Request, res: Response) {
    try {
      const { street, city, postalCode, gpsLatitude, gpsLongitude, isDefault } = req.body;
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const address = await AddressService.createAddress(userId, street, city, isDefault, postalCode, gpsLatitude, gpsLongitude);
      res.json({ data: address });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
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
