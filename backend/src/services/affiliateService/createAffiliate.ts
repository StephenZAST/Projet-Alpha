import { supabase } from '../../config/supabase';
import { Affiliate, AffiliateStatus } from '../../models/affiliate';
import { CodeGenerator } from '../../utils/codeGenerator';
import { AppError, errorCodes } from '../../utils/errors';

const affiliatesTable = 'affiliates';

export async function createAffiliate(
    firstName: string,
    lastName: string,
    email: string,
    phoneNumber: string,
    address: string,
    orderPreferences: Affiliate['orderPreferences'],
    paymentInfo: Affiliate['paymentInfo']
): Promise<Affiliate> {
    try {
        // Check if email is already used
        const { data: existingAffiliate, error: existingError } = await supabase
            .from(affiliatesTable)
            .select('*')
            .eq('email', email)
            .single();

        if (existingAffiliate) {
            throw new AppError(400, 'Email already registered as affiliate', errorCodes.EMAIL_ALREADY_REGISTERED);
        }

        const affiliate: Omit<Affiliate, 'id'> = {
            firstName,
            lastName,
            email,
            phoneNumber,
            address,
            orderPreferences,
            status: AffiliateStatus.PENDING,
            paymentInfo,
            commissionRate: 10, // 10% default
            totalEarnings: 0,
            availableBalance: 0,
            referralCode: await CodeGenerator.generateAffiliateCode(),
            referralClicks: 0,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        };

        const { data, error } = await supabase.from(affiliatesTable).insert([affiliate]).select().single();

        if (error) {
            throw new AppError(500, 'Failed to create affiliate', errorCodes.AFFILIATE_CREATION_FAILED);
        }

        return { ...affiliate, id: data.id } as Affiliate;
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Failed to create affiliate', errorCodes.AFFILIATE_CREATION_FAILED);
    }
}
