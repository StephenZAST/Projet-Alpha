import { Request, Response, NextFunction } from 'express';
import { affiliateService } from '../services/affiliateService';
import { Affiliate, AffiliateStatus, CommissionWithdrawal } from '../models/affiliate';
import { PaymentMethod } from '../models/order';
import { AppError, errorCodes } from '../utils/errors';
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

class AffiliateController {
    async createAffiliate(req: Request, res: Response, next: NextFunction) {
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
    }

    async getAllAffiliates(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const affiliates = await affiliateService.getAllAffiliates();
            res.status(200).json(affiliates);
        } catch (error) {
            next(new AppError(500, 'Failed to get affiliates', errorCodes.AFFILIATE_NOT_FOUND));
        }
    }

    async getAffiliateById(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { id } = req.params;
            const affiliate = await affiliateService.getAffiliateById(id);
            if (!affiliate) {
                throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
            }
            res.status(200).json(affiliate);
        } catch (error) {
            if (error instanceof AppError) {
                next(error);
            }
            else {
                next(new AppError(500, 'Failed to get affiliate', errorCodes.AFFILIATE_NOT_FOUND));
            }
        }
    }

    async updateAffiliate(req: Request, res: Response, next: NextFunction): Promise<void> {
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
                next(error)
            }
            else {
                next(new AppError(500, 'Failed to update affiliate', errorCodes.AFFILIATE_UPDATE_FAILED));
            }
        }
    }

    async deleteAffiliate(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { id } = req.params;
            await affiliateService.deleteAffiliate(id);
            res.status(204).send();
        } catch (error) {
            if (error instanceof AppError) {
                next(error);
            } else {
                next(new AppError(500, 'Failed to delete affiliate', errorCodes.AFFILIATE_DELETION_FAILED));
            }
        }
    }

    async requestCommissionWithdrawal(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { affiliateId, amount, paymentMethod } = req.body;
            const withdrawal = await affiliateService.requestCommissionWithdrawal(
                affiliateId,
                amount,
                paymentMethod
            );
            res.status(200).json(withdrawal);
        } catch (error) {
            next(new AppError(500, 'Failed to request commission withdrawal', errorCodes.INVALID_REQUEST));
        }
    }

    async getCommissionWithdrawals(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const withdrawals = await affiliateService.getCommissionWithdrawals();
            res.status(200).json(withdrawals);
        } catch (error) {
            next(new AppError(500, 'Failed to get commission withdrawals', errorCodes.INVALID_REQUEST));
        }
    }

    async updateCommissionWithdrawalStatus(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { withdrawalId, status } = req.body;
            const updatedWithdrawal = await affiliateService.updateCommissionWithdrawalStatus(withdrawalId, status);
            res.status(200).json(updatedWithdrawal);
        } catch (error) {
            next(new AppError(500, 'Failed to update commission withdrawal status', errorCodes.INVALID_REQUEST));
        }
    }
}

export const affiliateController = new AffiliateController();
