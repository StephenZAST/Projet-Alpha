import { Request, Response, NextFunction } from 'express';
import { affiliateService } from '../../services/affiliateService';
import { AppError, errorCodes } from '../../utils/errors';

export const approveAffiliate = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { id } = req.params;
        await affiliateService.approveAffiliate(id);
        res.status(200).json({ message: 'Affiliate approved' });
    } catch (error) {
        if (error instanceof AppError) {
            next(error);
        } else {
            next(new AppError(500, 'Failed to approve affiliate', errorCodes.AFFILIATE_APPROVAL_FAILED));
        }
    }
};
