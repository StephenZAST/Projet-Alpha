import { db } from '../firebase';
import { Bill, BillStatus, PaymentMethod } from '../../models/bill';
import { AppError, errorCodes } from '../../utils/errors';
import { Timestamp } from 'firebase-admin/firestore';

export class PaymentProcessingService {
  async payBill(billId: string, paymentMethod: PaymentMethod, amountPaid: number, userId: string): Promise<Bill> {
    try {
      const bill = await db.collection('bills').doc(billId).get();
      if (!bill.exists) {
        throw new AppError(404, 'Bill not found', errorCodes.BILL_NOT_FOUND);
      }

      const billData = bill.data() as Bill;

      if (billData.status === BillStatus.PAID) {
        throw new AppError(400, 'Bill is already paid', errorCodes.BILL_ALREADY_PAID);
      }

      if (amountPaid < billData.totalAmount) {
        throw new AppError(400, 'Insufficient payment amount', errorCodes.INSUFFICIENT_PAYMENT);
      }

      if (!paymentMethod) {
        throw new AppError(400, 'Payment method is required', errorCodes.PAYMENT_METHOD_REQUIRED);
      }

      const paymentResult = await this.processPayment(paymentMethod, amountPaid, userId, billId);

      if (paymentResult.success) {
        await db.collection('bills').doc(billId).update({
          status: BillStatus.PAID,
          paymentMethod: paymentMethod,
          paymentDate: Timestamp.now(),
          paymentReference: paymentResult.transactionId,
          updatedAt: Timestamp.now()
        });
        const updatedBill = await db.collection('bills').doc(billId).get();
        return { id: updatedBill.id, ...updatedBill.data() } as Bill;
      } else {
        throw new AppError(500, 'Payment processing failed', errorCodes.PAYMENT_PROCESSING_FAILED);
      }
    } catch (error) {
      console.error('Error paying bill:', error);
      throw error;
    }
  }

  async refundBill(billId: string, refundReason: string, userId: string, refundAmount?: number): Promise<Bill> {
    try {
      const bill = await db.collection('bills').doc(billId).get();
      if (!bill.exists) {
        throw new AppError(404, 'Bill not found', errorCodes.BILL_NOT_FOUND);
      }

      const billData = bill.data() as Bill;

      if (billData.status !== BillStatus.PAID) {
        throw new AppError(400, 'Cannot refund an unpaid bill', errorCodes.INVALID_REFUND_REQUEST);
      }

      if (!billData.paymentMethod) {
        throw new AppError(400, 'Payment method is missing for this bill', errorCodes.PAYMENT_METHOD_MISSING);
      }

      const refundAmountToProcess = refundAmount !== undefined ? refundAmount : billData.totalAmount;

      if (refundAmountToProcess <= 0 || refundAmountToProcess > billData.totalAmount) {
        throw new AppError(400, 'Invalid refund amount', errorCodes.INVALID_REFUND_AMOUNT);
      }

      const refundResult = await this.processRefund(billData.paymentMethod, refundAmountToProcess, userId, billId);

      if (refundResult.success) {
        await db.collection('bills').doc(billId).update({
          status: BillStatus.REFUNDED,
          refundAmount: refundAmountToProcess,
          refundDate: Timestamp.now(),
          refundReference: refundResult.transactionId,
          refundReason,
          updatedAt: Timestamp.now()
        });
        const updatedBill = await db.collection('bills').doc(billId).get();
        return { id: updatedBill.id, ...updatedBill.data() } as Bill;
      } else {
        throw new AppError(500, 'Refund processing failed', errorCodes.REFUND_PROCESSING_FAILED);
      }
    } catch (error) {
      console.error('Error refunding bill:', error);
      throw error;
    }
  }

  // Placeholder for payment processing logic
  private async processPayment(paymentMethod: PaymentMethod, amount: number, userId: string, billId: string): Promise<{ success: boolean; transactionId?: string }> {
    console.log(`Processing payment for user ${userId}, bill ${billId}, amount ${amount}, using ${paymentMethod}`);
    return { success: true, transactionId: 'mock-transaction-id' };
  }

  // Placeholder for refund processing logic
  private async processRefund(paymentMethod: PaymentMethod, amount: number, userId: string, billId: string): Promise<{ success: boolean; transactionId?: string }> {
    console.log(`Processing refund for user ${userId}, bill ${billId}, amount ${amount}, using ${paymentMethod}`);
    return { success: true, transactionId: 'mock-refund-transaction-id' };
  }
}
