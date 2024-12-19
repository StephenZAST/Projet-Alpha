import { supabase } from '../../config/supabase';
import { Affiliate } from '../../models/affiliate';
import { AppError, errorCodes } from '../../utils/errors';

const affiliatesTable = 'affiliates';

export async function getAllAffiliates(): Promise<Affiliate[]> {
    try {
        const { data, error } = await supabase
            .from(affiliatesTable)
            .select('*')
            .order('createdAt', { ascending: false });

        if (error) {
            throw new AppError(500, 'Failed to fetch all affiliates', errorCodes.AFFILIATE_FETCH_FAILED);
        }

        return data as Affiliate[];
    } catch (error) {
        throw new AppError(500, 'Failed to fetch all affiliates', errorCodes.AFFILIATE_FETCH_FAILED);
    }
}
