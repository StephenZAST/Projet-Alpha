import { Request, Response, NextFunction } from 'express';
import { affiliateService } from '../../services/affiliateService';
import { AppError, errorCodes } from '../../utils/errors';

export const getPendingAffiliates = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const affiliates = await affiliateService.getPendingAffiliates();
        res.status(200).json(affiliates);
    } catch (error) {
        if (error instanceof AppError) {
            next(error);
        } else {
            next(new AppError(500, 'Failed to get pending affiliates', errorCodes.AFFILIATE_NOT_FOUND));
        }
    }
};
