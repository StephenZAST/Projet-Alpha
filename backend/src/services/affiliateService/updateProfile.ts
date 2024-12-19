import { supabase } from '../../config/supabase';
import { Affiliate } from '../../models/affiliate';
import { AppError, errorCodes } from '../../utils/errors';

const affiliatesTable = 'affiliates';

export async function updateProfile(affiliateId: string, updates: Partial<Omit<Affiliate, 'id' | 'status' | 'referralCode'>>): Promise<void> {
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
                ...updates,
                updatedAt: new Date().toISOString()
            })
            .eq('id', affiliateId);

        if (error) {
            throw new AppError(500, 'Failed to update affiliate profile', errorCodes.AFFILIATE_UPDATE_FAILED);
        }
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Failed to update affiliate profile', errorCodes.AFFILIATE_UPDATE_FAILED);
    }
}
