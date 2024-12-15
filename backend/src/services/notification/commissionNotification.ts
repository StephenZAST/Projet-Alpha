import { createClient } from '@supabase/supabase-js';
import { AppError, errorCodes } from '../../utils/errors';
import { sendEmail } from '../../utils/email';
import { Notification, NotificationType, NotificationStatus, DeliveryChannel, NotificationPriority } from '../../models/notification';
import { notificationManagement } from './notificationManagement';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

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
      const { data: affiliate, error: affiliateError } = await supabase.from('affiliates').select('*').eq('id', affiliateId).single();

      if (affiliateError) {
        throw new AppError(404, 'Affiliate not found', errorCodes.AFFILIATE_NOT_FOUND);
      }

      // Create notification
      await notificationManagement.createNotification({
        recipientId: affiliateId,
        title: 'Commission Approved',
        message: `Your commission of ${commission.commissionAmount} FCFA for order #${commission.orderId} has been approved.`,
        type: NotificationType.COMMISSION_APPROVED,
        status: NotificationStatus.UNREAD,
        deliveryChannel: DeliveryChannel.EMAIL,
        recipientRole: 'affiliate',
        priority: NotificationPriority.LOW,
        isRead: false,
        data: {
          orderId: commission.orderId,
          orderAmount: commission.orderAmount,
          commissionAmount: commission.commissionAmount
        }
      });

      // Send email notification if email is available
      if (affiliate.email) {
        const emailData = {
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

        await sendEmail(emailData);
      }
    } catch (error) {
      if (error instanceof AppError) throw error;
      throw new AppError(500, 'Failed to send commission approval notification', errorCodes.NOTIFICATION_SEND_ERROR);
    }
  }
}

export const commissionNotification = new CommissionNotification();
