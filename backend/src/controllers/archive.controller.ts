import { Request, Response } from 'express';
import { ArchiveService } from '../services/archive.service'; 

export class ArchiveController {
  static async getArchivedOrders(req: Request, res: Response) {
    try {
      const userId = req.user?.id;
      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;

      const archives = await ArchiveService.getArchivedOrders(userId, page, limit);
      res.json(archives);
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  } 

  static async runArchiveCleanup(req: Request, res: Response) {
    try {
      const days = parseInt(req.query.days as string) || 30;
      const archivedCount = await ArchiveService.archiveOldOrders(days);
      res.json({ archived: archivedCount });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}
 