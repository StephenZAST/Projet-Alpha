 import { Request, Response, NextFunction } from 'express';
import { BillingService } from '../services/billing';
import { Bill } from '../models/bill';
import { AppError, errorCodes } from '../utils/errors';
import Joi from 'joi';
import { UserRole } from '../models/user';

// Placeholder for billing validation schema
const billingValidationSchema = Joi.object({
    // Define validation rules here
});

const billingService = new BillingService();

class BillingController {
    async createBill(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            // Replace with actual validation and bill creation logic
            const validatedData = await billingValidationSchema.validateAsync(req.body);
            const billData: Bill = {
                ...validatedData,
                userId: req.user!.id, // Assuming req.user is populated by authentication middleware
            };

            const newBill = await billingService.createBill(billData);
            res.status(201).json(newBill);
            return; // Add explicit return
        } catch (error) {
            if (error instanceof Joi.ValidationError) {
                next(new AppError(400, error.details.map(detail => detail.message).join(', '), errorCodes.VALIDATION_ERROR));
            } else {
                next(error);
            }
        }
    }

    async getAllBills(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { page = 1, limit = 10, status } = req.query;

            // Validate query parameters
            const paginationSchema = Joi.object({
                page: Joi.number().integer().min(1),
                limit: Joi.number().integer().min(1).max(100),
                status: Joi.string().valid('pending', 'paid', 'overdue'),
            });
            const { error, value: validatedQuery } = paginationSchema.validate({ page, limit, status });

            if (error) {
                throw new AppError(400, error.details.map(detail => detail.message).join(', '), errorCodes.VALIDATION_ERROR);
            }

            const bills = await billingService.getBillsForUser(
                req.user!.id,
                { page: validatedQuery.page, limit: validatedQuery.limit, status: validatedQuery.status }
            );
            res.status(200).json(bills);
            return; // Add explicit return
        } catch (error) {
            next(error);
        }
    }

    async getBillById(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { id } = req.params;

            // Validate ID parameter
            const idSchema = Joi.string().required();
            const { error } = idSchema.validate(id);

            if (error) {
                throw new AppError(400, error.details.map(detail => detail.message).join(', '), errorCodes.VALIDATION_ERROR);
            }

            const bill = await billingService.getBillById(id);
            if (!bill) {
                throw new AppError(404, 'Bill not found', errorCodes.BILL_NOT_FOUND);
            }

            // Check if the user is authorized to view the bill
            if (bill.userId !== req.user!.id && req.user!.role !== UserRole.SUPER_ADMIN) {
                throw new AppError(403, 'Forbidden', errorCodes.FORBIDDEN);
            }

            res.status(200).json(bill);
            return; // Add explicit return
        } catch (error) {
            next(error);
        }
    }

    async updateBill(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { id } = req.params;

            // Validate ID parameter
            const idSchema = Joi.string().required();
            const { error: idError } = idSchema.validate(id);

            if (idError) {
                throw new AppError(400, idError.details.map(detail => detail.message).join(', '), errorCodes.VALIDATION_ERROR);
            }

            const validatedData = await billingValidationSchema.validateAsync(req.body);
            const billData: Partial<Bill> = {
                ...validatedData,
            };

            const bill = await billingService.getBillById(id);
            if (!bill) {
                throw new AppError(404, 'Bill not found', errorCodes.BILL_NOT_FOUND);
            }

            // Check if the user is authorized to update the bill
            if (bill.userId !== req.user!.id && req.user!.role !== UserRole.SUPER_ADMIN) {
                throw new AppError(403, 'Forbidden', errorCodes.FORBIDDEN);
            }

            const updatedBill = await billingService.updateBill(id, billData);
            res.status(200).json(updatedBill);
            return; // Add explicit return
        } catch (error) {
            if (error instanceof Joi.ValidationError) {
                next(new AppError(400, error.details.map(detail => detail.message).join(', '), errorCodes.VALIDATION_ERROR));
            } else {
                next(error);
            }
        }
    }

    async deleteBill(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { id } = req.params;

            // Validate ID parameter
            const idSchema = Joi.string().required();
            const { error: idError } = idSchema.validate(id);

            if (idError) {
                throw new AppError(400, idError.details.map(detail => detail.message).join(', '), errorCodes.VALIDATION_ERROR);
            }

            const bill = await billingService.getBillById(id);
            if (!bill) {
                throw new AppError(404, 'Bill not found', errorCodes.BILL_NOT_FOUND);
            }

            // Check if the user is authorized to delete the bill
            if (bill.userId !== req.user!.id && req.user!.role !== UserRole.SUPER_ADMIN) {
                throw new AppError(403, 'Forbidden', errorCodes.FORBIDDEN);
            }

            await billingService.deleteBill(id);
            res.status(204).send();
            return; // Add explicit return
        } catch (error) {
            next(error);
        }
    }

    async generateInvoices(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            // Placeholder for invoice generation logic
            // Add your invoice generation logic here
            res.status(200).json({ message: 'Invoices generated successfully' });
            return; // Add explicit return
        } catch (error) {
            next(error);
        }
    }
}

export const billingController = new BillingController();
