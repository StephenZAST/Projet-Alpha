import { Request, Response, NextFunction } from 'express';
import { affiliateService } from '../../services/affiliateService';

export async function getAffiliateById(req: Request, res: Response, next: NextFunction): Promise<void> {
  const { id } = req.params;

  try {
    const affiliate = await affiliateService.getAffiliateById(id);

    if (affiliate) {
      res.status(200).json(affiliate);
    } else {
      res.status(404).json({ message: 'Affiliate not found' });
    }
  } catch (error) {
    next(error);
  }
}
