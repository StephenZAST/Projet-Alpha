import { db } from '../firebase';
import { Bill, BillStatus } from '../../models/bill';
import { AppError, errorCodes } from '../../utils/errors';
import { Timestamp } from 'firebase-admin/firestore';

export class BillManagementService {
  async createBill(billData: Bill): Promise<Bill> {
    try {
      const billRef = await db.collection('bills').add({
        ...billData,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        status: 'pending' // Default status
      });
      const billSnapshot = await billRef.get();
      return { id: billSnapshot.id, ...billSnapshot.data() } as Bill;
    } catch (error) {
      console.error('Error creating bill:', error);
      throw new AppError(500, 'Failed to create bill', errorCodes.BILL_CREATION_FAILED);
    }
  }

  async getBillById(billId: string): Promise<Bill | null> {
    try {
      const billDoc = await db.collection('bills').doc(billId).get();
      if (!billDoc.exists) {
        return null;
      }
      return { id: billDoc.id, ...billDoc.data() } as Bill;
    } catch (error) {
      console.error('Error getting bill:', error);
      throw new AppError(500, 'Failed to get bill', errorCodes.BILL_NOT_FOUND);
    }
  }

  async updateBill(billId: string, updates: Partial<Bill>): Promise<Bill> {
    try {
      await db.collection('bills').doc(billId).update({
        ...updates,
        updatedAt: Timestamp.now()
      });
      const updatedBill = await this.getBillById(billId);
      if (!updatedBill) {
        throw new AppError(404, 'Bill not found after update', errorCodes.BILL_NOT_FOUND);
      }
      return updatedBill;
    } catch (error) {
      console.error('Error updating bill:', error);
      throw new AppError(500, 'Failed to update bill', errorCodes.BILL_UPDATE_FAILED);
    }
  }

  async getBillsForUser(userId: string, options: {
    page?: number;
    limit?: number;
    status?: BillStatus;
  } = {}): Promise<{ bills: Bill[]; total: number }> {
    try {
      let query = db.collection('bills').where('userId', '==', userId);

      if (options.status) {
        query = query.where('status', '==', options.status);
      }

      const totalSnapshot = await query.get();
      const total = totalSnapshot.size;

      if (options.page && options.limit) {
        const offset = (options.page - 1) * options.limit;
        query = query.offset(offset).limit(options.limit);
      }

      const billsSnapshot = await query.orderBy('createdAt', 'desc').get();
      const bills = billsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Bill));

      return { bills, total };
    } catch (error) {
      console.error('Error getting bills for user:', error);
      throw new AppError(500, 'Failed to get bills for user', errorCodes.BILL_FETCH_FAILED);
    }
  }

  async getBillsForSubscriptionPlan(planId: string, options: {
    page?: number;
    limit?: number;
    status?: BillStatus;
  } = {}): Promise<{ bills: Bill[]; total: number }> {
    try {
      let query = db.collection('bills').where('subscriptionPlanId', '==', planId);

      if (options.status) {
        query = query.where('status', '==', options.status);
      }

      const totalSnapshot = await query.get();
      const total = totalSnapshot.size;

      if (options.page && options.limit) {
        const offset = (options.page - 1) * options.limit;
        query = query.offset(offset).limit(options.limit);
      }

      const billsSnapshot = await query.orderBy('createdAt', 'desc').get();
      const bills = billsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() } as Bill));

      return { bills, total };
    } catch (error) {
      console.error('Error getting bills for subscription plan:', error);
      throw new AppError(500, 'Failed to get bills for subscription plan', errorCodes.BILL_FETCH_FAILED);
    }
  }
}
