import { Request, Response, NextFunction } from 'express';
import { affiliateService } from '../../services/affiliateService';
import { AppError, errorCodes } from '../../utils/errors';

export const getAffiliateProfile = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { id } = req.params;
        const affiliate = await affiliateService.getAffiliateProfile(id);
        if (!affiliate) {
            throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
        }
        res.status(200).json(affiliate);
    } catch (error) {
        if (error instanceof AppError) {
            next(error);
        } else {
            next(new AppError(500, 'Failed to get affiliate profile', errorCodes.AFFILIATE_NOT_FOUND));
        }
    }
};
