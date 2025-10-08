// Ajout pour la modification de l'adresse d'une commande
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
import { Request, Response } from 'express';
import { AddressService } from '../services/address.service'; 
import { Address } from '../models/types';

export class AddressController {
  // PATCH /orders/:orderId/address
  static async updateOrderAddress(req: Request, res: Response) {
    try {
      const orderId = req.params.orderId;
      const { addressId } = req.body;
      const userId = req.user?.id;
      const userRole = req.user?.role ?? '';

      console.log('[updateOrderAddress] Payload:', req.body);
      console.log('[updateOrderAddress] orderId:', orderId, 'addressId:', addressId, 'userId:', userId, 'userRole:', userRole);

      if (!userId) {
        console.error('[updateOrderAddress] No userId');
        return res.status(401).json({ error: 'Unauthorized' });
      }
      if (!addressId) {
        console.error('[updateOrderAddress] addressId manquant');
        return res.status(400).json({ error: 'addressId requis' });
      }

      // Vérifier que la commande existe et appartient à l'utilisateur ou admin
      const order = await prisma.orders.findUnique({ where: { id: orderId } });
      console.log('[updateOrderAddress] Order trouvé:', order);
      if (!order) {
        console.error('[updateOrderAddress] Commande non trouvée');
        return res.status(404).json({ error: 'Commande non trouvée' });
      }
      if (order.userId !== userId && !['ADMIN', 'SUPER_ADMIN'].includes(userRole)) {
        console.error('[updateOrderAddress] Non autorisé à modifier cette commande');
        return res.status(403).json({ error: 'Non autorisé à modifier cette commande' });
      }

      // Vérifier que l'adresse existe et appartient à l'utilisateur
      const address = await prisma.addresses.findUnique({ where: { id: addressId } });
      console.log('[updateOrderAddress] Adresse trouvée:', address);
      if (!address) {
        console.error('[updateOrderAddress] Adresse non trouvée');
        return res.status(404).json({ error: 'Adresse non trouvée' });
      }
      if (address.userId !== userId && !['ADMIN', 'SUPER_ADMIN'].includes(userRole)) {
        console.error('[updateOrderAddress] Non autorisé à utiliser cette adresse');
        return res.status(403).json({ error: 'Non autorisé à utiliser cette adresse' });
      }

      // Mettre à jour l'adresse de la commande
      try {
        const updatedOrder = await prisma.orders.update({
          where: { id: orderId },
          data: { addressId }
        });
        console.log('[updateOrderAddress] Commande mise à jour:', updatedOrder);
        res.json({ success: true, data: updatedOrder });
      } catch (updateError) {
        const errMsg = (updateError instanceof Error) ? updateError.message : String(updateError);
        console.error('[updateOrderAddress] Erreur lors de la mise à jour:', updateError);
        res.status(500).json({ error: 'Failed to update order address', details: errMsg });
      }
    } catch (error) {
      const errMsg = (error instanceof Error) ? error.message : String(error);
      console.error('Update order address error:', error);
      res.status(500).json({ error: 'Failed to update order address', details: errMsg });
    }
  }
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

      console.log('[updateAddress] Request params:', req.params);
      console.log('[updateAddress] Request body:', req.body);
      console.log('[updateAddress] User info:', { userId, userRole });

      if (!userId) {
        console.error('[updateAddress] No userId found in request');
        return res.status(401).json({ error: 'Unauthorized - User not authenticated' });
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
