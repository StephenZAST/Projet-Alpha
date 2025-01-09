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

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      // Récupérer uniquement les adresses de l'utilisateur connecté
      const addresses = await AddressService.getAllAddresses(userId);
      res.json({ data: addresses });
    } catch (error) {
      // ...existing error handling...
    }
  }

  static async updateAddress(req: Request, res: Response) {
    try {
      const addressId = req.params.addressId;
      const userId = req.user?.id;

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const existingAddress = await AddressService.getAddressById(addressId);
      
      if (!existingAddress) {
        return res.status(404).json({ error: 'Adresse non trouvée' });
      }

      // Utiliser user_id au lieu de userId
      if (existingAddress.user_id !== userId) {
        return res.status(403).json({ 
          error: 'Vous ne pouvez modifier que vos propres adresses' 
        });
      }

      // Procéder à la mise à jour si l'adresse appartient à l'utilisateur
      const { 
        name,
        street, 
        city, 
        postal_code, 
        gps_latitude, 
        gps_longitude, 
        is_default 
      } = req.body;

      console.log('Updating address:', {
        addressId,
        userId,
        existingAddress,
        requestBody: req.body
      });

      const updatedAddress = await AddressService.updateAddress(
        addressId,
        userId,
        name,
        street,
        city,
        postal_code,
        gps_latitude,
        gps_longitude,
        is_default
      );

      res.json({ data: updatedAddress });
    } catch (error) {
      console.error('Update address error:', error);
      res.status(500).json({ error: 'Failed to update address' });
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
