import { Request, Response, NextFunction } from 'express';
import { affiliateService } from '../../services/affiliateService';
import { AppError, errorCodes } from '../../utils/errors';

export const getCommissionWithdrawals = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const withdrawals = await affiliateService.getCommissionWithdrawals();
        res.status(200).json(withdrawals);
    } catch (error) {
        if (error instanceof AppError) {
            next(error);
        } else {
            next(new AppError(500, 'Failed to get commission withdrawals', errorCodes.COMMISSION_WITHDRAWAL_FETCH_FAILED));
        }
    }
};
