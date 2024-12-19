import { supabase } from '../../config/supabase';
import { Affiliate } from '../../models/affiliate';
import { AppError, errorCodes } from '../../utils/errors';

const affiliatesTable = 'affiliates';
const commissionsTable = 'commissions';
const commissionWithdrawalsTable = 'commissionWithdrawals';

export async function getAnalytics(): Promise<{
    totalAffiliates: number;
    pendingAffiliates: number;
    activeAffiliates: number;
    totalCommissions: number;
    totalWithdrawals: number;
}> {
    try {
        const { count: totalAffiliates } = await supabase
            .from(affiliatesTable)
            .select('*', { count: 'exact' });

        const { count: pendingAffiliates } = await supabase
            .from(affiliatesTable)
            .select('*', { count: 'exact' })
            .eq('status', 'PENDING');

        const { count: activeAffiliates } = await supabase
            .from(affiliatesTable)
            .select('*', { count: 'exact' })
            .eq('status', 'ACTIVE');

        const { count: totalCommissions } = await supabase
            .from(commissionsTable)
            .select('*', { count: 'exact' });

        const { count: totalWithdrawals } = await supabase
            .from(commissionWithdrawalsTable)
            .select('*', { count: 'exact' });

        return {
            totalAffiliates: totalAffiliates || 0,
            pendingAffiliates: pendingAffiliates || 0,
            activeAffiliates: activeAffiliates || 0,
            totalCommissions: totalCommissions || 0,
            totalWithdrawals: totalWithdrawals || 0
        };
    } catch (error) {
        throw new AppError(500, 'Failed to fetch analytics', 'AFFILIATE_ANALYTICS_FETCH_FAILED');
    }
}
