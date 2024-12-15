import { Request, Response, NextFunction } from 'express';
import { affiliateService } from '../../services/affiliateService';
import { AppError, errorCodes } from '../../utils/errors';

export const getAllAffiliates = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const affiliates = await affiliateService.getAllAffiliates();
        res.status(200).json(affiliates);
    } catch (error) {
        if (error instanceof AppError) {
            next(error);
        } else {
            next(new AppError(500, 'Failed to get all affiliates', errorCodes.AFFILIATE_FETCH_FAILED));
        }
    }
};
