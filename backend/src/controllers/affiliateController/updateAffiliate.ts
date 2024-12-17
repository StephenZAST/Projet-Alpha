import { Request, Response, NextFunction } from 'express';
import { affiliateService } from '../../services/affiliateService';
import { AppError, errorCodes } from '../../utils/errors';
import Joi from 'joi';
import { Affiliate, AffiliateStatus, PaymentMethod } from '../../models/affiliate';

export const affiliateValidationSchema = Joi.object({
    firstName: Joi.string().required(),
    lastName: Joi.string().required(),
    email: Joi.string().email().required(),
    phoneNumber: Joi.string().required(),
    address: Joi.string().required(),
    status: Joi.string().valid(...Object.values(AffiliateStatus)).required(),
    commissionRate: Joi.number().min(0).max(1).required(),
    paymentInfo: Joi.object({
        preferredMethod: Joi.string().valid(...Object.values(PaymentMethod)).required(),
        mobileMoneyNumber: Joi.string().when('preferredMethod', {
            is: PaymentMethod.MOBILE_MONEY,
            then: Joi.string().required(),
            otherwise: Joi.string().optional()
        }),
        bankInfo: Joi.object({
            accountNumber: Joi.string().required(),
            bankName: Joi.string().required(),
            branchName: Joi.string().optional()
        }).when('preferredMethod', {
            is: PaymentMethod.BANK_TRANSFER,
            then: Joi.object().required(),
            otherwise: Joi.object().optional()
        })
    }).required(),
    orderPreferences: Joi.object({
        allowedOrderTypes: Joi.array().items(Joi.string()).required(),
        allowedPaymentMethods: Joi.array().items(Joi.string().valid(...Object.values(PaymentMethod))).required()
    }).required()
});

export const updateAffiliate = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { id } = req.params;
        const validatedData = await affiliateValidationSchema.validateAsync(req.body);
        const affiliateData: Partial<Affiliate> = {
            ...validatedData,
            status: validatedData.status as AffiliateStatus,
            paymentInfo: {
                ...validatedData.paymentInfo,
                preferredMethod: validatedData.paymentInfo.preferredMethod as PaymentMethod
            },
            orderPreferences: {
                ...validatedData.orderPreferences,
                allowedOrderTypes: validatedData.orderPreferences.allowedOrderTypes,
                allowedPaymentMethods: validatedData.orderPreferences.allowedPaymentMethods.map((method: string) => method as PaymentMethod)
            }
        };

        const updatedAffiliate = await affiliateService.updateAffiliate(id, affiliateData);
        if (!updatedAffiliate) {
            throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
        }
        res.status(200).json(updatedAffiliate);
    } catch (error) {
        if (error instanceof Joi.ValidationError) {
            next(new AppError(400, error.details.map(detail => detail.message).join(', '), errorCodes.VALIDATION_ERROR));
        } else if (error instanceof AppError) {
            next(error);
        } else {
            next(new AppError(500, 'Failed to update affiliate', errorCodes.AFFILIATE_UPDATE_FAILED));
        }
    }
};
