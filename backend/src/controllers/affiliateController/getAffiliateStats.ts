import { Request, Response, NextFunction } from 'express';
import { affiliateService } from '../../services/affiliateService';
import { AppError, errorCodes } from '../../utils/errors';

export const getAffiliateStats = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { id } = req.params;
        const stats = await affiliateService.getAffiliateStats(id);
        res.status(200).json(stats);
    } catch (error) {
        if (error instanceof AppError) {
            next(error);
        } else {
            next(new AppError(500, 'Failed to get affiliate stats', errorCodes.AFFILIATE_STATS_FETCH_FAILED));
        }
    }
};
