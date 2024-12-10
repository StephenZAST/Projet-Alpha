import { db } from '../firebase';
import { Bill } from '../../models/bill';
import { AppError, errorCodes } from '../../utils/errors';

export class BillingAnalyticsService {
  async getBillingStats(startDate: Date, endDate: Date): Promise<{
    totalRevenue: number;
    totalBills: number;
    averageBillAmount: number;
    billsByStatus: { [status: string]: number };
  }> {
    try {
      const billsSnapshot = await db.collection('bills')
        .where('createdAt', '>=', startDate)
        .where('createdAt', '<=', endDate)
        .get();

      const totalRevenue = billsSnapshot.docs.reduce((sum, doc) => sum + (doc.data() as Bill).totalAmount, 0);
      const totalBills = billsSnapshot.size;
      const averageBillAmount = totalBills > 0 ? totalRevenue / totalBills : 0;

      const billsByStatus: { [status: string]: number } = {};
      billsSnapshot.docs.forEach(doc => {
        const billStatus = (doc.data() as Bill).status;
        billsByStatus[billStatus] = (billsByStatus[billStatus] || 0) + 1;
      });

      return { totalRevenue, totalBills, averageBillAmount, billsByStatus };
    } catch (error) {
      console.error('Error getting billing stats:', error);
      throw new AppError(500, 'Failed to get billing stats', errorCodes.BILLING_STATS_FETCH_FAILED);
    }
  }
}
