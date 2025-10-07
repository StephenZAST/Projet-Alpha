import { Request, Response } from 'express';
import prisma from '../../config/prisma';

export class LinkedClientsController {
  // Pour un affilié : voir la liste de ses clients liés et leurs commandes
  static async getLinkedClients(req: Request, res: Response) {
    try {
      const affiliateProfile = await prisma.affiliate_profiles.findFirst({
        where: { userId: req.user?.id },
        select: { id: true, affiliate_code: true }
      });
      if (!affiliateProfile) {
        return res.status(404).json({ error: 'Profil affilié non trouvé' });
      }
      const links = await prisma.affiliate_client_links.findMany({
        where: { affiliate_id: affiliateProfile.id },
        include: {
          client: { select: { id: true, first_name: true, last_name: true, email: true } }
        },
        orderBy: { created_at: 'desc' }
      });
      // Pour chaque client, récupérer ses commandes associées à ce code affilié
      const result = await Promise.all(links.map(async link => {
        const affiliateCode = affiliateProfile.affiliate_code; // Récupérer le code depuis le profil
        const orders = await prisma.orders.findMany({
          where: {
            userId: link.client.id,
            affiliateCode: affiliateCode
          },
          orderBy: { createdAt: 'desc' }
        });
        return {
          client: link.client,
          link: { id: link.id, start_date: link.start_date, end_date: link.end_date },
          orders
        };
      }));
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}
