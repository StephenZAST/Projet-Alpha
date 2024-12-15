import supabase from '../../config/supabase';
import { Affiliate } from '../../models/affiliate';
import { AppError, errorCodes } from '../../utils/errors';

const affiliatesTable = 'affiliates';

export async function getAffiliateById(affiliateId: string): Promise<Affiliate> {
    try {
        const { data: affiliate, error: affiliateError } = await supabase
            .from(affiliatesTable)
            .select('*')
            .eq('id', affiliateId)
            .single();

        if (affiliateError) {
            throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
        }

        return affiliate as Affiliate;
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Failed to get affiliate', errorCodes.AFFILIATE_NOT_FOUND);
    }
}
