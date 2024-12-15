import { Request, Response, NextFunction } from 'express';
import { affiliateService } from '../../services/affiliateService';
import { AppError, errorCodes } from '../../utils/errors';
import { PayoutStatus } from '../../models/affiliate';

export const processWithdrawal = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { id } = req.params;
        const { adminId, status, notes } = req.body;

        if (!Object.values(PayoutStatus).includes(status)) {
            throw new AppError(400, 'Invalid payout status', errorCodes.INVALID_STATUS);
        }

        await affiliateService.processWithdrawal(id, adminId, status, notes);
        res.status(200).json({ message: 'Withdrawal processed' });
    } catch (error) {
        if (error instanceof AppError) {
            next(error);
        } else {
            next(new AppError(500, 'Failed to process withdrawal', errorCodes.WITHDRAWAL_PROCESSING_FAILED));
        }
    }
};
