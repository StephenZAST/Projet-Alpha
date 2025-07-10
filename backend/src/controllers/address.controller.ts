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

      // Détermination du userId cible
      let targetUserId = req.user.id;
      // Si admin/superadmin ET user_id fourni dans le body, on utilise ce user_id
      if (
        (req.user.role === 'ADMIN' || req.user.role === 'SUPER_ADMIN') &&
        req.body.user_id
      ) {
        targetUserId = req.body.user_id;
      }

      const address = await AddressService.createAddress(
        targetUserId,
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
      const userRole = req.user?.role ?? '';

      if (!userId) {
        return res.status(401).json({ error: 'Unauthorized' });
      }

      const existingAddress = await AddressService.getAddressById(addressId);
      if (!existingAddress) {
        return res.status(404).json({ error: 'Adresse non trouvée' });
      }

      // Autoriser la modification si propriétaire OU admin/superadmin
      if (existingAddress.user_id !== userId && !['ADMIN', 'SUPER_ADMIN'].includes(userRole)) {
        return res.status(403).json({ error: 'Non autorisé à modifier cette adresse' });
      }

      // Utiliser le user_id de l'adresse pour la mise à jour (admin peut modifier pour autrui)
      const {
        name,
        street,
        city,
        postal_code,
        gps_latitude,
        gps_longitude,
        is_default
      } = req.body;

      const updatedAddress = await AddressService.updateAddress(
        addressId,
        existingAddress.user_id,
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
      const userRole = req.user?.role ?? '';

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const address = await AddressService.getAddressById(addressId);
      if (!address) return res.status(404).json({ error: 'Adresse non trouvée' });

      // Autoriser la suppression si propriétaire OU admin/superadmin
      if (address.user_id !== userId && !['ADMIN', 'SUPER_ADMIN'].includes(userRole)) {
        return res.status(403).json({ error: 'Non autorisé à supprimer cette adresse' });
      }

      await AddressService.deleteAddress(addressId, address.user_id);
      res.json({ message: 'Address deleted successfully' });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getAddressesByUserId(req: Request, res: Response) {
    try {
      const { userId } = req.params;
      if (!userId) {
        return res.status(400).json({ error: 'userId is required' });
      }
      const addresses = await AddressService.getAllAddresses(userId);
      res.json({ data: addresses });
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch addresses' });
    }
  }
}
