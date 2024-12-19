import { supabase } from '../../config/supabase';
import { Affiliate, CommissionWithdrawal, PayoutStatus } from '../../models/affiliate';
import { AppError, errorCodes } from '../../utils/errors';

const affiliatesTable = 'affiliates';
const commissionsTable = 'commissions';
const commissionWithdrawalsTable = 'commissionWithdrawals';

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
        const { data: affiliate, error: affiliateError } = await supabase
            .from(affiliatesTable)
            .select('*')
            .eq('id', affiliateId)
            .single();

        if (affiliateError) {
            throw new AppError(404, 'Affiliate not found', 'AFFILIATE_NOT_FOUND');
        }

        const { data: commissions, error: commissionsError } = await supabase
            .from(commissionsTable)
            .select('*')
            .eq('affiliateId', affiliateId);

        if (commissionsError) {
            throw new AppError(500, 'Failed to fetch commissions', 'AFFILIATE_STATS_FETCH_FAILED');
        }

        const { data: withdrawals, error: withdrawalsError } = await supabase
            .from(commissionWithdrawalsTable)
            .select('*')
            .eq('affiliateId', affiliateId);

        if (withdrawalsError) {
            throw new AppError(500, 'Failed to fetch withdrawals', 'AFFILIATE_STATS_FETCH_FAILED');
        }

        const totalEarnings = (commissions || []).reduce((sum: any, commission: { amount: any; }) => sum + commission.amount, 0);
        const availableBalance = totalEarnings - (withdrawals || []).reduce((sum: any, withdrawal: { amount: any; }) => sum + withdrawal.amount, 0);
        const pendingCommissions = (commissions || []).filter((commission: { status: string; }) => commission.status === 'PENDING').length;
        const totalReferrals = affiliate.referralClicks;
        const conversionRate = (affiliate.totalEarnings > 0) ? (affiliate.totalEarnings / affiliate.referralClicks) * 100 : 0;

        const monthlyStats = (commissions || []).reduce((acc: { month: string; earnings: any; referrals: number; orders: number; }[], commission: { createdAt: string | number | Date; amount: any; }) => {
            const month = new Date(commission.createdAt).toLocaleString('default', { month: 'long', year: 'numeric' });
            const existingMonth = acc.find((stat: { month: string; }) => stat.month === month);

            if (existingMonth) {
                existingMonth.earnings += commission.amount;
                existingMonth.referrals += 1;
                existingMonth.orders += 1;
            } else {
                acc.push({
                    month,
                    earnings: commission.amount,
                    referrals: 1,
                    orders: 1
                });
            }

            return acc;
        }, [] as { month: string; earnings: number; referrals: number; orders: number }[]);

        const performanceMetrics = {
            avgOrderValue: (commissions || []).reduce((sum: any, commission: { amount: any; }) => sum + commission.amount, 0) / (commissions || []).length,
            totalOrders: (commissions || []).length,
            activeCustomers: (commissions || []).reduce((customers: any[], commission: { customerId: any; }) => {
                if (!customers.includes(commission.customerId)) {
                    customers.push(commission.customerId);
                }
                return customers;
            }, [] as string[]).length
        };

        return {
            totalEarnings,
            availableBalance,
            pendingCommissions,
            totalReferrals,
            conversionRate,
            monthlyStats,
            performanceMetrics
        };
    } catch (error) {
        throw new AppError(500, 'Failed to fetch affiliate stats', 'AFFILIATE_STATS_FETCH_FAILED');
    }
}
