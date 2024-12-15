import { Request, Response, NextFunction } from 'express';
import { affiliateService } from '../../services/affiliateService';
import { Affiliate, AffiliateStatus, CommissionWithdrawal, PayoutStatus } from '../../models/affiliate';
import { PaymentMethod } from '../../models/order';
import { AppError, errorCodes } from '../../utils/errors';
import Joi from 'joi';

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

export const createAffiliate = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const validatedData = await affiliateValidationSchema.validateAsync(req.body);
        const affiliateData: Affiliate = {
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

        const newAffiliate = await affiliateService.createAffiliate(
            affiliateData.firstName,
            affiliateData.lastName,
            affiliateData.email,
            affiliateData.phoneNumber,
            affiliateData.address,
            affiliateData.orderPreferences,
            affiliateData.paymentInfo
        );
        res.status(201).json(newAffiliate);
    } catch (error) {
        if (error instanceof Joi.ValidationError) {
            next(new AppError(400, error.details.map(detail => detail.message).join(', '), errorCodes.VALIDATION_ERROR));
        } else {
            next(new AppError(500, 'Failed to create affiliate', errorCodes.AFFILIATE_CREATION_FAILED));
        }
    }
};
