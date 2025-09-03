import { Request, Response } from 'express';
import { OfferService } from '../services/offer.service'; 

export class OfferController {
  // Client Endpoints
  static async getAvailableOffers(req: Request, res: Response) {
    const { userId } = req.user as { userId: string };
    const offers = await OfferService.getAvailableOffers(userId);
    return res.json({ success: true, data: offers });
  }

  static async subscribeToOffer(req: Request, res: Response) {
    const { userId } = req.user as { userId: string };
    const { offerId } = req.params;
    await OfferService.subscribeToOffer(userId, offerId);
    return res.json({ success: true, message: 'Successfully subscribed to offer' });
  }

  static async unsubscribeFromOffer(req: Request, res: Response) {
    const { userId } = req.user as { userId: string };
    const { offerId } = req.params;
    await OfferService.unsubscribeFromOffer(userId, offerId);
    return res.json({ success: true, message: 'Successfully unsubscribed from offer' });
  }

  static async getUserSubscriptions(req: Request, res: Response) {
    const { userId } = req.user as { userId: string };
    const subscriptions = await OfferService.getUserSubscriptions(userId);
    return res.json({ success: true, data: subscriptions });
  }

  // Admin Endpoints
  static async createOffer(req: Request, res: Response) {
    const offer = await OfferService.createOffer(req.body);
    return res.status(201).json({ success: true, data: offer });
  }

  static async updateOffer(req: Request, res: Response) {
    try {
      const { offerId } = req.params;
      const offer = await OfferService.updateOffer(offerId, req.body);
      return res.json({ success: true, data: offer });
    } catch (error) {
      console.error('[OfferController] updateOffer error:', error);
      return res.status(500).json({ 
        success: false, 
        error: 'Failed to update offer',
        message: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }

  static async getSubscribers(req: Request, res: Response) {
    const { offerId } = req.params;
    const subscribers = await OfferService.getSubscribers(offerId);
    return res.json({ success: true, data: subscribers });
  }

  static async deleteOffer(req: Request, res: Response) {
    const { offerId } = req.params;
    await OfferService.deleteOffer(offerId);
    return res.json({ success: true, message: 'Offer deleted successfully' });
  }

  static async getOfferById(req: Request, res: Response) {
    const { offerId } = req.params;
    const offer = await OfferService.getOfferById(offerId);
    return res.json({ success: true, data: offer });
  }

  static async toggleOfferStatus(req: Request, res: Response) {
    const { offerId } = req.params;
    const { isActive } = req.body;
    
    if (typeof isActive !== 'boolean') {
      return res.status(400).json({ error: 'isActive must be a boolean' });
    }

    const offer = await OfferService.toggleOfferStatus(offerId, isActive);
    return res.json({ success: true, data: offer });
  }

  // Admin: liste toutes les offres
  static async getAllOffers(req: Request, res: Response) {
    const offers = await OfferService.getAllOffers();
    return res.json({ success: true, data: offers });
  }
}
