import { createClient } from '@supabase/supabase-js';
import { PaymentMethod, Payment, PaymentStatus, RefundReason, Currency, PaymentMethodType } from '../models/payment';
import { AppError, errorCodes } from '../utils/errors';
import { getPayment, createPayment, updatePayment, deletePayment } from './paymentService/paymentManagement';
import { getPaymentMethods, addPaymentMethod, removePaymentMethod, setDefaultPaymentMethod } from './paymentService/paymentMethodManagement';
import { getRefund, createRefund, updateRefund, deleteRefund } from './paymentService/refundManagement';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
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
    const paymentData: Omit<Payment, 'id'> = {
      userId: data.userId,
      orderId: data.orderId,
      amount: data.amount,
      currency: data.currency,
      paymentMethodId: data.paymentMethodId,
      description: data.description,
      status: 'SUCCEEDED' as PaymentStatus,
      createdAt: new Date().toISOString(),
    };

    return createPayment(paymentData);
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
    try {
      let query = this.paymentsRef.select('*').eq('userId', userId);

      if (options.status) {
        query = query.eq('status', options.status);
      }

      const startAt = (options.page - 1) * options.limit;

      const [totalSnapshot, paymentsSnapshot] = await Promise.all([
        this.paymentsRef.select().count().eq('userId', userId).single(),
        query
          .order('createdAt', { ascending: false })
          .range(startAt, startAt + options.limit - 1)
          .select()
      ]);

      const total = totalSnapshot.count;
      const payments = paymentsSnapshot.data.map(doc => ({ id: doc.id, ...doc } as Payment));

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
    const refundData: Omit<Refund, 'id'> = {
      userId: data.userId,
      paymentId: data.paymentId,
      amount: data.amount || 0,
      reason: data.reason || 'OTHER',
      status: 'SUCCEEDED' as PaymentStatus,
      createdAt: new Date().toISOString(),
    };

    const refund = await createRefund(refundData);

    return {
      id: refund.id,
      status: refund.status,
      amount: refund.amount,
    };
  }
}

export const paymentService = new PaymentService();
