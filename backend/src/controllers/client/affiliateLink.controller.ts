import { Request, Response } from 'express';
import prisma from '../../config/prisma';

export class ClientAffiliateLinkController {
  // Voir à quel affilié le client est lié (actuellement)
  static async getCurrentAffiliate(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });
      const now = new Date();
      const link = await prisma.affiliate_client_links.findFirst({
        where: {
          client_id: userId,
          start_date: { lte: now },
          OR: [
            { end_date: null },
            { end_date: { gte: now } }
          ],
          affiliate: {
            is_active: true,
            status: 'ACTIVE'
          }
        },
        include: {
          affiliate: {
            select: {
              id: true,
              affiliate_code: true,
              users: { select: { first_name: true, last_name: true, email: true } }
            }
          }
        },
        orderBy: { start_date: 'desc' }
      });
      if (!link) return res.json({ data: null });
      res.json({ data: link.affiliate });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}
