import supabase from '../../config/supabase';
import { Affiliate, AffiliateStatus } from '../../models/affiliate';
import { AppError, errorCodes } from '../../utils/errors';
import { NotificationService, NotificationType } from '../notifications';

const affiliatesTable = 'affiliates';

export async function approveAffiliate(affiliateId: string): Promise<void> {
    try {
        const { data: affiliate, error: affiliateError } = await supabase
            .from(affiliatesTable)
            .select('*')
            .eq('id', affiliateId)
            .single();

        if (affiliateError) {
            throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
        }

        if (affiliate?.status === AffiliateStatus.ACTIVE) {
            throw new AppError(400, 'Affiliate is already active', errorCodes.AFFILIATE_ALREADY_ACTIVE);
        }

        const { error } = await supabase
            .from(affiliatesTable)
            .update({
                status: AffiliateStatus.ACTIVE,
                updatedAt: new Date().toISOString()
            })
            .eq('id', affiliateId);

        if (error) {
            throw new AppError(500, 'Failed to approve affiliate', errorCodes.AFFILIATE_UPDATE_FAILED);
        }

        const notificationService = new NotificationService();
        await notificationService.sendNotification(affiliateId, {
            type: NotificationType.AFFILIATE_APPROVED,
            title: 'Affiliate Application Approved',
            message: 'Your affiliate application has been approved. You can now start referring customers.',
            data: {}
        });
    } catch (error) {
        if (error instanceof AppError) throw error;
        throw new AppError(500, 'Failed to approve affiliate', errorCodes.AFFILIATE_UPDATE_FAILED);
    }
}
