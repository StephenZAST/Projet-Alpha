import { Request, Response, NextFunction } from 'express';
import { BillingService } from '../services/billing';
import { Bill } from '../models/bill';
import { AppError, errorCodes } from '../utils/errors';
import Joi from 'joi';

// Placeholder for billing validation schema
const billingValidationSchema = Joi.object({
    // Define validation rules here
});

const billingService = new BillingService();

class BillingController {
    async createBill(req: Request, res: Response, next: NextFunction) {
        try {
            // Replace with actual validation and bill creation logic
            const validatedData = await billingValidationSchema.validateAsync(req.body);
            const billData: Bill = {
                ...validatedData,
            };

            const newBill = await billingService.createBill(billData);
            res.status(201).json(newBill);
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
            // Assuming you want to add pagination or filtering, you can add query parameters
            const { page, limit, status } = req.query;
            // You would need to implement the logic to handle these in BillingService
            // For now, let's just get all bills without filtering
            const bills = await billingService.getBillsForUser(req.user!.id);
            res.status(200).json(bills);
        } catch (error) {
            next(error);
        }
    }

    async getBillById(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { id } = req.params;
            const bill = await billingService.getBillById(id);
            if (!bill) {
                throw new AppError(404, 'Bill not found', errorCodes.BILL_NOT_FOUND);
            }
            res.status(200).json(bill);
        } catch (error) {
            next(error);
        }
    }

    async updateBill(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            const { id } = req.params;
            const validatedData = await billingValidationSchema.validateAsync(req.body);
            const billData: Partial<Bill> = {
                ...validatedData,
            };

            const updatedBill = await billingService.updateBill(id, billData);
            if (!updatedBill) {
                throw new AppError(404, 'Bill not found', errorCodes.BILL_NOT_FOUND);
            }
            res.status(200).json(updatedBill);
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
            // Assuming you have a deleteBill method in BillingService
            // await billingService.deleteBill(id);
            res.status(204).send();
        } catch (error) {
            next(error);
        }
    }

    async generateInvoices(req: Request, res: Response, next: NextFunction): Promise<void> {
        try {
            // Placeholder for invoice generation logic
            // Add your invoice generation logic here
            res.status(200).json({ message: 'Invoices generated successfully' });
        } catch (error) {
            next(error);
        }
    }
}

export const billingController = new BillingController();
