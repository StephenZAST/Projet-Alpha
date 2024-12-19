import { supabase } from '../../config/supabase';
import { Affiliate } from '../../models/affiliate';
import { AppError, errorCodes } from '../../utils/errors';

const affiliatesTable = 'affiliates';

export async function updateAffiliate(affiliateId: string, affiliateData: Partial<Affiliate>): Promise<Affiliate> {
    try {
        const { data: affiliate, error: affiliateError } = await supabase
            .from(affiliatesTable)
            .select('*')
            .eq('id', affiliateId)
            .single();

        if (affiliateError) {
            throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
        }

        const { error } = await supabase
            .from(affiliatesTable)
            .update({
                ...affiliateData,
                updatedAt: new Date().toISOString()
            })
            .eq('id', affiliateId);

        if (error) {
            throw new AppError(500, 'Failed to update affiliate', errorCodes.AFFILIATE_UPDATE_FAILED);
        }

        return {
            id: affiliateId,
            ...affiliate,
            ...affiliateData,
            updatedAt: new Date().toISOString()
        } as Affiliate;
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Failed to update affiliate', errorCodes.AFFILIATE_UPDATE_FAILED);
    }
}
