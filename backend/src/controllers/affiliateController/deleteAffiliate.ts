import { Request, Response, NextFunction } from 'express';
import { affiliateService } from '../../services/affiliateService';
import { AppError, errorCodes } from '../../utils/errors';

export async function deleteAffiliate(req: Request, res: Response, next: NextFunction): Promise<void> {
  const { id } = req.params;

  try {
    await affiliateService.deleteAffiliate(id);
    res.status(204).send();
  } catch (error) {
    if (error instanceof AppError) {
      next(error);
    } else {
      next(new AppError(500, 'Failed to delete affiliate', errorCodes.AFFILIATE_DELETION_FAILED));
    }
  }
}
