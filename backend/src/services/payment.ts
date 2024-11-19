import { db } from '../config/firebase';
import { PaymentMethod, Payment, PaymentStatus, RefundReason, Currency, PaymentMethodType } from '../types/payment';

export class PaymentService {
  private paymentMethodsRef = db.collection('paymentMethods');
  private paymentsRef = db.collection('payments');
  private refundsRef = db.collection('refunds');

  async getPaymentMethods(userId: string): Promise<PaymentMethod[]> {
    const snapshot = await this.paymentMethodsRef
      .where('userId', '==', userId)
      .get();

    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    } as PaymentMethod));
  }

  async addPaymentMethod(userId: string, data: {
    type: PaymentMethodType;
    token: string;
    isDefault?: boolean;
  }): Promise<PaymentMethod> {
    // Here you would typically interact with a payment processor (e.g., Stripe)
    // to create a payment method and get back a token/ID

    const paymentMethodData: Omit<PaymentMethod, 'id'> = {
      userId,
      type: data.type,
      token: data.token,
      isDefault: data.isDefault || false,
      createdAt: new Date(),
    };

    const docRef = await this.paymentMethodsRef.add(paymentMethodData);
    
    if (data.isDefault) {
      await this.updateOtherPaymentMethodsDefault(userId, docRef.id);
    }

    return {
      id: docRef.id,
      ...paymentMethodData,
    };
  }
  private async updateOtherPaymentMethodsDefault(userId: string, excludeId: string) {
    const batch = db.batch();
    const snapshot = await this.paymentMethodsRef
      .where('userId', '==', userId)
      .where('isDefault', '==', true)
      .get();

    snapshot.docs.forEach(doc => {
      if (doc.id !== excludeId) {
        batch.update(doc.ref, { isDefault: false });
      }
    });

    await batch.commit();
  }

  async removePaymentMethod(userId: string, paymentMethodId: string): Promise<void> {
    const docRef = this.paymentMethodsRef.doc(paymentMethodId);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new Error('Payment method not found');
    }

    if (doc.data()?.userId !== userId) {
      throw new Error('Unauthorized');
    }

    await docRef.delete();
  }

  async setDefaultPaymentMethod(userId: string, paymentMethodId: string): Promise<void> {
    const docRef = this.paymentMethodsRef.doc(paymentMethodId);
    const doc = await docRef.get();

    if (!doc.exists) {
      throw new Error('Payment method not found');
    }

    if (doc.data()?.userId !== userId) {
      throw new Error('Unauthorized');
    }

    await this.updateOtherPaymentMethodsDefault(userId, paymentMethodId);
    await docRef.update({ isDefault: true });
  }

  async processPayment(data: {
    userId: string;
    orderId: string;
    amount: number;
    currency: Currency;
    paymentMethodId: string;
    description?: string;
  }): Promise<Payment> {
    // Here you would typically interact with a payment processor (e.g., Stripe)
    // to process the actual payment

    const paymentData: Omit<Payment, 'id'> = {
      userId: data.userId,
      orderId: data.orderId,
      amount: data.amount,
      currency: data.currency,
      paymentMethodId: data.paymentMethodId,
      description: data.description,
      status: 'SUCCEEDED',
      createdAt: new Date(),
    };

    const docRef = await this.paymentsRef.add(paymentData);

    return {
      id: docRef.id,
      ...paymentData,
    };
  }
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
    let query = this.paymentsRef.where('userId', '==', userId);

    if (options.status) {
      query = query.where('status', '==', options.status);
    }

    const startAt = (options.page - 1) * options.limit;
    
    const [totalSnapshot, paymentsSnapshot] = await Promise.all([
      query.count().get(),
      query
        .orderBy('createdAt', 'desc')
        .offset(startAt)
        .limit(options.limit)
        .get(),
    ]);

    const total = totalSnapshot.data().count;
    const payments = paymentsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    } as Payment));

    return {
      payments,
      pagination: {
        total,
        pages: Math.ceil(total / options.limit),
        current: options.page,
        limit: options.limit,
      },
    };
  }

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
    const paymentRef = this.paymentsRef.doc(data.paymentId);
    const payment = await paymentRef.get();

    if (!payment.exists) {
      throw new Error('Payment not found');
    }

    if (payment.data()?.userId !== data.userId) {
      throw new Error('Unauthorized');
    }

    // Here you would typically interact with a payment processor (e.g., Stripe)
    // to process the actual refund

    const refundData = {
      userId: data.userId,
      paymentId: data.paymentId,
      amount: data.amount || payment.data()?.amount,
      reason: data.reason,
      status: 'SUCCEEDED' as PaymentStatus,
      createdAt: new Date(),
    };

    const docRef = await this.refundsRef.add(refundData);

    // Update original payment status
    await paymentRef.update({ status: 'REFUNDED' });

    return {
      id: docRef.id,
      status: refundData.status,
      amount: refundData.amount,
    };
  }
}
