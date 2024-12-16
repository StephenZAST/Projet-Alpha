import { createClient } from '@supabase/supabase-js';
import { PaymentMethod, Payment, PaymentStatus, RefundReason, Currency, PaymentMethodType, Refund } from '../models/payment';
import { AppError, errorCodes } from '../utils/errors';
import { getPayment, createPayment, updatePayment, deletePayment } from './paymentService/paymentManagement';
import { getPaymentMethods, addPaymentMethod, removePaymentMethod, setDefaultPaymentMethod } from './paymentService/paymentMethodManagement';
import { getRefund, createRefund, updateRefund, deleteRefund } from './paymentService/refundManagement';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL and SUPABASE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const paymentMethodsTable = 'paymentMethods';
const paymentsTable = 'payments';
const refundsTable = 'refunds';

export class PaymentService {
  private paymentMethodsRef = supabase.from(paymentMethodsTable);
  private paymentsRef = supabase.from(paymentsTable);
  private refundsRef = supabase.from(refundsTable);

  /**
   * Get payment methods for a user
   */
  async getPaymentMethods(userId: string): Promise<PaymentMethod[]> {
    return getPaymentMethods(userId);
  }

  /**
   * Add a new payment method
   */
  async addPaymentMethod(userId: string, data: {
    type: PaymentMethodType;
    token: string;
    isDefault?: boolean;
  }): Promise<PaymentMethod> {
    return addPaymentMethod(userId, data);
  }

  /**
   * Remove a payment method
   */
  async removePaymentMethod(userId: string, paymentMethodId: string): Promise<void> {
    return removePaymentMethod(userId, paymentMethodId);
  }

  /**
   * Set default payment method
   */
  async setDefaultPaymentMethod(userId: string, paymentMethodId: string): Promise<void> {
    return setDefaultPaymentMethod(userId, paymentMethodId);
  }

  /**
   * Process a payment
   */
  async processPayment(data: {
    userId: string;
    orderId: string;
    amount: number;
    currency: Currency;
    paymentMethodId: string;
    description?: string;
  }): Promise<Payment> {
    // Validate payment method
    const { data: paymentMethod, error: paymentMethodError } = await this.paymentMethodsRef.select('*').eq('id', data.paymentMethodId).single();
    if (paymentMethodError) {
      throw new AppError(404, 'Payment method not found', errorCodes.NOT_FOUND);
    }

    // Process payment
    const paymentData: Payment = {
      userId: data.userId,
      orderId: data.orderId,
      amount: data.amount,
      currency: data.currency,
      paymentMethodId: data.paymentMethodId,
      description: data.description,
      status: 'PENDING' as PaymentStatus,
      createdAt: new Date().toISOString(),
      data: {},
      error: null,
    };

    const result = await createPayment(paymentData);
    if (result.error) {
      throw new AppError(500, 'Failed to create payment', errorCodes.DATABASE_ERROR);
    }

    const payment = result.data;

    // Simulate payment processing (replace with actual payment processing logic)
    const paymentSuccess = true; // Replace with actual payment processing logic

    if (paymentSuccess) {
      await updatePayment(payment.id, { status: 'SUCCEEDED' });
    } else {
      await updatePayment(payment.id, { status: 'FAILED' });
    }

    return payment;
  }

  /**
   * Get payment history
   */
  async getPaymentHistory(userId: string, options: {
    page: number;
    limit: number;
    status?: string;
  }): Promise<{
    payments: Payment[];
    pagination: {
      total: number;
      pages: number;
      current: number;
      limit: number;
    };
  }> {
    if (options.page < 1 || options.limit < 1) {
      throw new AppError(400, 'Invalid pagination parameters', errorCodes.INVALID_PAGINATION);
    }

    try {
      let query = this.paymentsRef.select('*').eq('userId', userId);

      if (options.status) {
        query = query.eq('status', options.status);
      }

      const { count, error: totalError } = await this.paymentsRef.select('*', { count: 'exact' }).eq('userId', userId).single();
      if (totalError) {
        throw new AppError(500, 'Failed to fetch payment count', errorCodes.DATABASE_ERROR);
      }

      const total = count !== null ? count : 0;

      const startAt = (options.page - 1) * options.limit;

      const { data: paymentsSnapshot, error: paymentsError } = await query
        .order('createdAt', { ascending: false })
        .range(startAt, startAt + options.limit - 1)
        .select();
      if (paymentsError) {
        throw new AppError(500, 'Failed to fetch payments', errorCodes.DATABASE_ERROR);
      }

      const payments = paymentsSnapshot.map(doc => ({ id: doc.id, ...doc } as Payment));

      return {
        payments,
        pagination: {
          total,
          pages: Math.ceil(total / options.limit),
          current: options.page,
          limit: options.limit,
        },
      };
    } catch (error) {
      console.error('Error fetching payment history:', error);
      throw error;
    }
  }

  /**
   * Process a refund
   */
  async processRefund(data: {
    userId: string;
    paymentId: string;
    amount?: number;
    reason?: RefundReason;
  }): Promise<{
    id: string;
    status: PaymentStatus;
    amount: number;
  }> {
    const result = await getPayment(data.paymentId);
    if (result === null) {
      throw new AppError(404, 'Payment not found', errorCodes.NOT_FOUND);
    }

    if (result.error) {
      throw new AppError(404, 'Payment not found', errorCodes.NOT_FOUND);
    }

    const payment = result.data;

    if (payment.status !== 'SUCCEEDED') {
      throw new AppError(400, 'Payment cannot be refunded', errorCodes.INVALID_ID);
    }

    const refundData: Refund = {
      userId: data.userId,
      paymentId: data.paymentId,
      amount: data.amount || payment.amount,
      reason: data.reason || ('OTHER' as RefundReason),
      status: 'PENDING' as PaymentStatus,
      createdAt: new Date().toISOString(),
      data: {},
      error: null,
    };

    const refundResult = await createRefund(refundData);
    if (refundResult.error) {
      throw new AppError(500, 'Failed to create refund', errorCodes.DATABASE_ERROR);
    }

    const refund = refundResult.data;

    // Simulate refund processing (replace with actual refund processing logic)
    const refundSuccess = true; // Replace with actual refund processing logic

    if (refundSuccess) {
      await updateRefund(refund.id, { status: 'SUCCEEDED' });
    } else {
      await updateRefund(refund.id, { status: 'FAILED' });
    }

    return {
      id: refund.id,
      status: refund.status,
      amount: refund.amount,
    };
  }
}

export const paymentService = new PaymentService();
