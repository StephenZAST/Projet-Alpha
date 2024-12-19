import { supabase } from '../../config/supabase';
import { Affiliate } from '../../models/affiliate';
import { AppError, errorCodes } from '../../utils/errors';

const affiliatesTable = 'affiliates';
const commissionsTable = 'commissions';
const commissionWithdrawalsTable = 'commissionWithdrawals';

export async function deleteAffiliate(affiliateId: string): Promise<void> {
    try {
        const { data: affiliate, error: affiliateError } = await supabase
            .from(affiliatesTable)
            .select('*')
            .eq('id', affiliateId)
            .single();

        if (affiliateError) {
            throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
        }

        // Delete the affiliate
        const { error: deleteError } = await supabase
            .from(affiliatesTable)
            .delete()
            .eq('id', affiliateId);

        if (deleteError) {
            throw new AppError(500, 'Failed to delete affiliate', errorCodes.AFFILIATE_DELETION_FAILED);
        }

        // Delete associated commissions
        const { data: commissions, error: commissionsError } = await supabase
            .from(commissionsTable)
            .select('*')
            .eq('affiliateId', affiliateId);

        if (commissionsError) {
            throw new AppError(500, 'Failed to fetch commissions', errorCodes.AFFILIATE_DELETION_FAILED);
        }

        const commissionsDeletePromises = commissions?.map((commission: { id: string }) => supabase.from(commissionsTable).delete().eq('id', commission.id));
        await Promise.all(commissionsDeletePromises || []);

        // Delete associated withdrawal requests
        const { data: withdrawals, error: withdrawalsError } = await supabase
            .from(commissionWithdrawalsTable)
            .select('*')
            .eq('affiliateId', affiliateId);

        if (withdrawalsError) {
            throw new AppError(500, 'Failed to fetch withdrawal requests', errorCodes.AFFILIATE_DELETION_FAILED);
        }

        const withdrawalsDeletePromises = withdrawals?.map((withdrawal: { id: string }) => supabase.from(commissionWithdrawalsTable).delete().eq('id', withdrawal.id));
        await Promise.all(withdrawalsDeletePromises || []);

        // TODO: Consider deleting associated notifications
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Failed to delete affiliate', errorCodes.AFFILIATE_DELETION_FAILED);
    }
}
