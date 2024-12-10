import { db } from '../../config/firebase';
import { Affiliate } from '../../models/affiliate';
import { Commission } from '../../models/commission';
import { AppError, errorCodes } from '../../utils/errors';

const affiliatesRef = db.collection('affiliates');
const commissionsRef = db.collection('commissions');
const withdrawalsRef = db.collection('commission-withdrawals');

export async function getAnalytics(): Promise<{
    totalAffiliates: number;
    pendingAffiliates: number;
    activeAffiliates: number;
    totalCommissions: number;
    totalWithdrawals: number;
}> {
    try {
        const [affiliatesSnapshot, commissionsSnapshot, withdrawalsSnapshot] = await Promise.all([
            affiliatesRef.get(),
            commissionsRef.get(),
            withdrawalsRef.get()
        ]);

        const affiliates = affiliatesSnapshot.docs.map(doc => doc.data() as Affiliate);

        return {
            totalAffiliates: affiliates.length,
            pendingAffiliates: affiliates.filter(a => a.status === 'PENDING').length,
            activeAffiliates: affiliates.filter(a => a.status === 'ACTIVE').length,
            totalCommissions: commissionsSnapshot.size,
            totalWithdrawals: withdrawalsSnapshot.size
        };
    } catch (error) {
        throw new AppError(500, 'Failed to fetch analytics', errorCodes.ANALYTICS_NOT_FOUND);
    }
}

export async function getAffiliateStats(affiliateId: string): Promise<{
    totalEarnings: number;
    availableBalance: number;
    pendingCommissions: number;
    totalReferrals: number;
    conversionRate: number;
    monthlyStats: {
        month: string;
        earnings: number;
        referrals: number;
        orders: number;
    }[];
    performanceMetrics: {
        avgOrderValue: number;
        totalOrders: number;
        activeCustomers: number;
    };
}> {
    try {
        // Get affiliate profile
        const affiliateDoc = await affiliatesRef.doc(affiliateId).get();
        if (!affiliateDoc.exists) {
            throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
        }
        const affiliate = affiliateDoc.data() as Affiliate;

        // Get all commissions for this affiliate
        const commissionsSnapshot = await commissionsRef
            .where('affiliateId', '==', affiliateId)
            .get();

        const commissions = commissionsSnapshot.docs.map(doc => doc.data() as Commission);

        // Calculate pending commissions
        const pendingCommissions = commissions.length > 0
            ? commissions
                .filter(c => c.status === 'PENDING')
                .reduce((sum, c) => sum + c.commissionAmount, 0)
            : 0;

        // Get referral orders from orders collection
        const ordersSnapshot = await db.collection('orders')
            .where('referralCode', '==', affiliate.referralCode)
            .get();

        const orders = ordersSnapshot.docs.map(doc => doc.data());

        // Calculate monthly stats for the last 6 months
        const monthlyStats = calculateMonthlyStats(commissions, orders);

        // Calculate performance metrics
        const performanceMetrics = calculatePerformanceMetrics(orders);

        // Calculate conversion rate (orders / total referral clicks)
        const conversionRate = affiliate.referralClicks ? (orders.length / affiliate.referralClicks) * 100 : 0;

        return {
            totalEarnings: affiliate.totalEarnings,
            availableBalance: affiliate.availableBalance,
            pendingCommissions,
            totalReferrals: orders.length,
            conversionRate,
            monthlyStats,
            performanceMetrics
        };
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Failed to fetch affiliate stats', errorCodes.AFFILIATE_STATS_FETCH_FAILED);
    }
}

function calculateMonthlyStats(commissions: Commission[], orders: any[]): {
    month: string;
    earnings: number;
    referrals: number;
    orders: number;
}[] {
    const last6Months = Array.from({ length: 6 }, (_, i) => {
        const date = new Date();
        date.setMonth(date.getMonth() - i);
        return date.toISOString().substring(0, 7); // YYYY-MM format
    });

    return last6Months.map(month => {
        const monthCommissions = commissions.filter(c =>
            c.createdAt.toDate().toISOString().startsWith(month)
        );
        const monthOrders = orders.filter(o =>
            o.createdAt?.toDate().toISOString().startsWith(month)
        );

        return {
            month,
            earnings: monthCommissions.reduce((sum, c) => sum + c.commissionAmount, 0),
            referrals: monthOrders.length,
            orders: monthOrders.length
        };
    });
}

function calculatePerformanceMetrics(orders: any[]): {
    avgOrderValue: number;
    totalOrders: number;
    activeCustomers: number;
} {
    const totalOrders = orders.length;
    const totalValue = orders.reduce((sum, order) => sum + (order.totalAmount || 0), 0);
    const uniqueCustomers = new Set(orders.map(order => order.customerId)).size;

    return {
        avgOrderValue: totalOrders > 0 ? totalValue / totalOrders : 0,
        totalOrders,
        activeCustomers: uniqueCustomers
    };
}
