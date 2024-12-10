import AppError from '../../utils/AppError';
import { errorCodes } from '../../utils/errors';
import { sendEmail } from '../../utils/email';
import { NotificationStatus, NotificationType } from '../notificationService';
import { notificationManagement } from './notificationManagement';

class Referral {
    /**
     * Send a referral invitation email
     * @param email Email address of the person being referred
     * @param referralCode Unique referral code for tracking
     */
    async sendReferralInvitation(email: string, referralCode: string): Promise<void> {
        try {
            // Email template for referral invitation
            const emailTemplate = {
                to: email, // Add 'to' property
                subject: 'You\'ve Been Invited to Join Our Platform!',
                html: `
                    <h2>Welcome to Our Platform!</h2>
                    <p>You've been invited to join our platform. Use the referral code below to get special benefits when you sign up:</p>
                    <div style="background-color: #f5f5f5; padding: 15px; margin: 20px 0; text-align: center; font-size: 24px; font-weight: bold;">
                        ${referralCode}
                    </div>
                    <p>Benefits of joining with this referral code:</p>
                    <ul>
                        <li>Special welcome bonus</li>
                        <li>Exclusive first-time offers</li>
                        <li>Additional rewards on your first purchase</li>
                    </ul>
                    <p>Click the link below to get started:</p>
                    <a href="${process.env.FRONTEND_URL}/signup?referralCode=${referralCode}" style="background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">
                        Sign Up Now
                    </a>
                    <p>This referral code will expire in 30 days.</p>
                `
            };

            // Send the email
            await sendEmail(emailTemplate); // Fix sendEmail usage

            // Log the invitation in notifications collection
            await notificationManagement.createNotification({
                userId: email, // Using email as userId for non-registered users
                title: 'Referral Invitation Sent',
                message: `Referral invitation sent to ${email} with code ${referralCode}`,
                type: NotificationType.REFERRAL_INVITATION,
                status: NotificationStatus.UNREAD,
                data: {
                    referralCode,
                    email
                }
            });

        } catch (error) {
            throw new AppError('Failed to send referral invitation', 500, errorCodes.NOTIFICATION_SEND_ERROR);
        }
    }
}

export const referral = new Referral();
