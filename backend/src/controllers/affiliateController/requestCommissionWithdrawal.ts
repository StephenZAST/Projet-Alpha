import { Request, Response, NextFunction } from 'express';
import { affiliateService } from '../../services/affiliateService';
import { AppError, errorCodes } from '../../utils/errors';
import { PaymentMethod } from '../../models/affiliate';

export const requestCommissionWithdrawal = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { affiliateId, amount, paymentMethod, paymentDetails } = req.body;

        if (!Object.values(PaymentMethod).includes(paymentMethod)) {
            throw new AppError(400, 'Invalid payment method', errorCodes.INVALID_PAYMENT_METHOD);
        }

        const withdrawal = await affiliateService.requestCommissionWithdrawal(
            affiliateId,
            amount,
            paymentMethod,
            paymentDetails
        );
        res.status(200).json(withdrawal);
    } catch (error) {
        if (error instanceof AppError) {
            next(error);
        } else {
            next(new AppError(500, 'Failed to request commission withdrawal', errorCodes.COMMISSION_WITHDRAWAL_REQUEST_FAILED));
        }
    }
};
