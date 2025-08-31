import { Request, Response } from 'express';
import { AuthService } from '../services/auth.service';

import { PrismaClient } from '@prisma/client';
import { OfferService } from '../services/offer.service';
import { SubscriptionService } from '../services/subscription.service';

const prisma = new PrismaClient();

export class UserController {
  /**
   * Endpoint pour récupérer les détails d'un utilisateur, avec ses offres actives et abonnements
   * GET /api/users/:userId/details
   */
  static async getUserDetails(req: Request, res: Response) {
    try {
      const userId = req.params.userId;
      const user = await prisma.users.findUnique({ where: { id: userId } });
      if (!user) return res.status(404).json({ error: 'Utilisateur non trouvé' });

      // Offres actives (abonnements)
      const activeOfferSubscriptions = await OfferService.getUserSubscriptions(userId);

      // Offres liées (historique)
      const userOffers = await prisma.user_offers.findMany({
        where: { userId },
        include: { offers: true }
      });

      // Abonnement utilisateur (plan)
      const activeSubscription = await SubscriptionService.getUserActiveSubscription(userId);

      return res.json({
        success: true,
        data: {
          user,
          activeOfferSubscriptions,
          userOffers,
          activeSubscription
        }
      });
    } catch (error: any) {
      console.error('[UserController] getUserDetails error:', error);
      return res.status(500).json({
        success: false,
        error: error.message || 'Erreur lors de la récupération des détails utilisateur',
        details: error.stack || error
      });
    }
  }
  /**
   * Endpoint de recherche paginée et filtrée d'utilisateurs (tous rôles, recherche, etc.)
   * GET /api/users/search?role=CLIENT&page=1&limit=10&query=...&filter=name
   */
  static async searchUsers(req: Request, res: Response) {
    try {
      const {
        query = '',
        filter = 'all',
        role = 'all',
        page = 1,
        limit = 10,
      } = req.query;

      // Appel du service centralisé
      const result = await AuthService.searchUsers({
        role: String(role),
        query: String(query),
        filter: String(filter),
        page: Number(page),
        limit: Number(limit)
      });

      // Enrichissement des données utilisateur pour chaque résultat
      const enrichedData = await Promise.all(result.data.map(async (user: any) => {
        // Offres actives (abonnements)
        const activeOfferSubscriptions = await OfferService.getUserSubscriptions(user.id);
        // Offres liées (historique)
        const userOffers = await prisma.user_offers.findMany({
          where: { userId: user.id },
          include: { offers: true }
        });
        // Abonnement utilisateur (plan)
        const activeSubscription = await SubscriptionService.getUserActiveSubscription(user.id);
        return {
          ...user,
          activeOfferSubscriptions,
          userOffers,
          activeSubscription
        };
      }));

      return res.json({
        success: true,
        data: enrichedData,
        pagination: result.pagination
      });
    } catch (error: any) {
      console.error('[UserController] Search error:', error);
      return res.status(500).json({
        success: false,
        error: error.message || 'Erreur lors de la recherche des utilisateurs',
        details: error.stack || error
      });
    }
  }
}
