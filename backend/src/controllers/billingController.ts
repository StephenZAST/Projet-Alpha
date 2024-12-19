import { Request, Response, NextFunction } from 'express';
import { BillingService } from '../services/billing';
import { Bill } from '../models/bill';
import { AppError, errorCodes } from '../utils/errors';
import { UserRole, User } from '../models/user';

const billingService = new BillingService();

interface AuthenticatedRequest extends Request {
    user?: User;
  }

export const createBill = async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<Response | void> => {
  try {
    const billData: Bill = {
      ...req.body,
      userId: req.user!.id, // Assuming req.user is populated by authentication middleware
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };

    const newBill = await billingService.createBill(billData);
    res.status(201).json(newBill);
  } catch (error) {
    next(error);
  }
};

export const updateBill = async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<Response | void> => {
  try {
    const { id } = req.params;
    const billData: Partial<Bill> = req.body;

    const updatedBill = await billingService.updateBill(id, billData);
    if (!updatedBill) {

      res.status(404).json({ message: 'Bill not found' });
      return;
    }

    res.status(200).json(updatedBill);
  } catch (error) {
    next(error);
  }

};
export const getBillById = async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<Response | void> => {
  try {
    const { id } = req.params;
    const bill = await billingService.getBillById(id);

    if (!bill) {
      return res.status(404).json({ message: 'Bill not found' });
    }

    if (bill.userId !== req.user!.id && req.user!.role !== UserRole.SUPER_ADMIN) {
      return res.status(403).json({ message: 'Unauthorized' });
    }

    res.status(200).json(bill);
  } catch (error) {
    next(error);
  }
};

export const getAllBills = async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<Response | void> => {
  try {
    const bills = await billingService.getAllBills();
    res.status(200).json(bills);
  } catch (error) {
    next(error);
  }
};

export const deleteBill = async (req: AuthenticatedRequest, res: Response, next: NextFunction): Promise<Response | void> => {
  try {
    const { id } = req.params;
    const bill = await billingService.getBillById(id);

    if (!bill) {
      return res.status(404).json({ message: 'Bill not found' });
    }

    if (bill.userId !== req.user!.id && req.user!.role !== UserRole.SUPER_ADMIN) {
      return res.status(403).json({ message: 'Unauthorized' });
    }

    await billingService.deleteBill(id);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};

export const generateInvoices = async (req: Request, res: Response, next: NextFunction): Promise<Response | void> => {
  try {
    const { userId, startDate, endDate } = req.body;

    if (!userId || !startDate || !endDate) {
      throw new AppError(400, 'Missing required parameters', errorCodes.MISSING_REQUIRED_PARAMETERS);
    }

    const invoices = await billingService.generateInvoices(userId, new Date(startDate), new Date(endDate));
    res.status(200).json(invoices);
  } catch (error) {
    if (error instanceof AppError) {
      next(error);
    } else {
      next(new AppError(500, 'Failed to generate invoices', errorCodes.INTERNAL_SERVER_ERROR));
    }
  }
};

export const billingController = {
  createBill,
  updateBill,
  getBillById,
  getAllBills,
  deleteBill,
  generateInvoices
}
