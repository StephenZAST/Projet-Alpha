import { db } from '../../config/firebase';
import AppError from '../../utils/AppError';
import { errorCodes } from '../../utils/errors';
import { sendEmail } from '../../utils/email';
import { NotificationStatus, NotificationType } from '../notificationService';
import { notificationManagement } from './notificationManagement';

class CommissionNotification {
    /**
     * Send a notification when a commission is approved
     */
    async sendCommissionApprovalNotification(
        affiliateId: string,
        commission: {
            orderId: string;
            orderAmount: number;
            commissionAmount: number;
        }
    ): Promise<void> {
        try {
            // Get affiliate details
            const affiliateDoc = await db.collection('affiliates').doc(affiliateId).get();
            const affiliate = affiliateDoc.data();

            if (!affiliate) {
                throw new AppError('Affiliate not found', 404, errorCodes.AFFILIATE_NOT_FOUND);
            }

            // Create notification
            await notificationManagement.createNotification({
                userId: affiliateId,
                title: 'Commission Approved',
                message: `Your commission of ${commission.commissionAmount} FCFA for order #${commission.orderId} has been approved.`,
                type: NotificationType.PAYMENT_STATUS,
                status: NotificationStatus.UNREAD,
                data: {
                    orderId: commission.orderId,
                    orderAmount: commission.orderAmount,
                    commissionAmount: commission.commissionAmount
                }
            });

            // Send email notification if email is available
            if (affiliate.email) {
                const emailData = { // Create email data object
                    to: affiliate.email,
                    subject: 'Commission Approved - Alpha Laundry',
                    html: `
                        <h2>Commission Approved</h2>
                        <p>Hello ${affiliate.fullName},</p>
                        <p>Your commission for order #${commission.orderId} has been approved.</p>
                        <p><strong>Order Amount:</strong> ${commission.orderAmount} FCFA</p>
                        <p><strong>Commission Amount:</strong> ${commission.commissionAmount} FCFA</p>
                        <p>This amount has been added to your available balance. You can request a withdrawal at any time.</p>
                        <p>Thank you for being a valued affiliate partner!</p>
                        <br>
                        <p>Best regards,</p>
                        <p>Alpha Laundry Team</p>
                    `
                };
                await sendEmail(emailData); // Pass email data object to sendEmail
            }
        } catch (error) {
            if (error instanceof AppError) throw error;
            throw new AppError(
                'Failed to send commission approval notification',
                500,
                errorCodes.NOTIFICATION_SEND_ERROR
            );
        }
    }
}

export const commissionNotification = new CommissionNotification();
