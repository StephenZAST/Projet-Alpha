import { Request, Response, NextFunction } from 'express';
import { affiliateService } from '../../services/affiliateService';
import { AppError, errorCodes } from '../../utils/errors';

export const getPendingWithdrawals = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const options = req.query;
        const withdrawals = await affiliateService.getPendingWithdrawals(options);
        res.status(200).json(withdrawals);
    } catch (error) {
        if (error instanceof AppError) {
            next(error);
        } else {
            next(new AppError(500, 'Failed to get pending withdrawals', errorCodes.PENDING_WITHDRAWALS_FETCH_FAILED));
        }
    }
};
