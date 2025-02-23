import { Request, Response } from 'express';
import { LoyaltyService } from '../services/loyalty.service';

export class LoyaltyController {
  static async earnPoints(req: Request, res: Response) {
    try {
      const { points, source, referenceId } = req.body;
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await LoyaltyService.earnPoints(userId, points, source, referenceId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  } 

  static async spendPoints(req: Request, res: Response) {
    try {
      const { points, source, referenceId } = req.body;
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await LoyaltyService.spendPoints(userId, points, source, referenceId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  } 

  static async getPointsBalance(req: Request, res: Response) {
    try {
      const userId = req.user?.id;

      if (!userId) return res.status(401).json({ error: 'Unauthorized' });

      const result = await LoyaltyService.getPointsBalance(userId);
      res.json({ data: result });
    } catch (error: any) {
      res.status(500).json({ error: error.message });
    }
  }
}
