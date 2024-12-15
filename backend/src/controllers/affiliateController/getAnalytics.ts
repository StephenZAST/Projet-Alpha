import { Request, Response, NextFunction } from 'express';
import { affiliateService } from '../../services/affiliateService';
import { AppError, errorCodes } from '../../utils/errors';

export const getAnalytics = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const analytics = await affiliateService.getAnalytics();
        res.status(200).json(analytics);
    } catch (error) {
        if (error instanceof AppError) {
            next(error);
        } else {
            next(new AppError(500, 'Failed to get analytics', errorCodes.AFFILIATE_ANALYTICS_FETCH_FAILED));
        }
    }
};
