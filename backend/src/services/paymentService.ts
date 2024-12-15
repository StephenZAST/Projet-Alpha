import { PaymentMethod, Payment, Refund, PaymentMethodType, PaymentStatus, Currency, RefundReason } from '../models/payment';
import { AppError, errorCodes } from '../utils/errors';
import { getPaymentMethods, addPaymentMethod, removePaymentMethod, setDefaultPaymentMethod } from './paymentService/paymentMethodManagement';
import { getPayment, createPayment, updatePayment, deletePayment } from './paymentService/paymentManagement';
import { getRefund, createRefund, updateRefund, deleteRefund } from './paymentService/refundManagement';

export class PaymentService {
  async getPaymentMethods(userId: string): Promise<PaymentMethod[]> {
    return getPaymentMethods(userId);
  }

  async addPaymentMethod(userId: string, data: {
    type: PaymentMethodType;
    token: string;
    isDefault?: boolean;
  }): Promise<PaymentMethod> {
    return addPaymentMethod(userId, data);
  }

  async removePaymentMethod(userId: string, paymentMethodId: string): Promise<void> {
    return removePaymentMethod(userId, paymentMethodId);
  }

  async setDefaultPaymentMethod(userId: string, paymentMethodId: string): Promise<void> {
    return setDefaultPaymentMethod(userId, paymentMethodId);
  }

  async getPayment(id: string): Promise<Payment | null> {
    return getPayment(id);
  }

  async createPayment(paymentData: Payment): Promise<Payment> {
    return createPayment(paymentData);
  }

  async updatePayment(id: string, paymentData: Partial<Payment>): Promise<Payment> {
    return updatePayment(id, paymentData);
  }

  async deletePayment(id: string): Promise<void> {
    return deletePayment(id);
  }

  async getRefund(id: string): Promise<Refund | null> {
    return getRefund(id);
  }

  async createRefund(refundData: Refund): Promise<Refund> {
    return createRefund(refundData);
  }

  async updateRefund(id: string, refundData: Partial<Refund>): Promise<Refund> {
    return updateRefund(id, refundData);
  }

  async deleteRefund(id: string): Promise<void> {
    return deleteRefund(id);
  }
}

export const paymentService = new PaymentService();
