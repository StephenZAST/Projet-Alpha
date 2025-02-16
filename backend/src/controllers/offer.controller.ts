import { Request, Response } from 'express';
import { OfferService } from '../services/offer.service';

export class OfferController {
  static async createOffer(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const offerData = req.body;
      const offer = await OfferService.createOffer(offerData);
      res.json({ data: offer });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async getAvailableOffers(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const offers = await OfferService.getAvailableOffers(userId);
      res.json({ data: offers });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  } 

  static async getOfferById(req: Request, res: Response) {
    try {
      const { offerId } = req.params;
      const offer = await OfferService.getOfferById(offerId);
      res.json({ data: offer });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async updateOffer(req: Request, res: Response) {
    try {
      const { offerId } = req.params;
      const updateData = req.body;
      const offer = await OfferService.updateOffer(offerId, updateData);
      res.json({ data: offer });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async deleteOffer(req: Request, res: Response) {
    try {
      const { offerId } = req.params;
      await OfferService.deleteOffer(offerId);
      res.json({ success: true });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }

  static async toggleOfferStatus(req: Request, res: Response) {
    try {
      const { offerId } = req.params;
      const { isActive } = req.body;
      const offer = await OfferService.toggleOfferStatus(offerId, isActive);
      res.json({ data: offer });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}
