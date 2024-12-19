import supabase from '../../config/supabase';
import { User, UserStatus } from '../../models/user';
import { AppError, errorCodes } from '../../utils/errors';
import { generateToken } from '../../utils/tokens';
import { sendVerificationEmail, sendPasswordResetEmail, sendWelcomeEmail } from '../emailService';
import { NotificationService } from '../notifications';
import { hashPassword } from '../../authModules/passwordUtils';

const usersTable = 'users';

export async function verifyEmail(token: string): Promise<void> {
  try {
    const { data: user, error: userError } = await supabase
      .from(usersTable)
      .select('*')
      .eq('emailVerificationToken', token)
      .single();

    if (userError) {
      throw new AppError(400, 'Invalid or expired verification token', errorCodes.INVALID_TOKEN);
    }

    if (!user) {
      throw new AppError(400, 'Invalid or expired verification token', errorCodes.INVALID_TOKEN);
    }

    const { error } = await supabase
      .from(usersTable)
      .update({
        emailVerified: true,
        status: UserStatus.ACTIVE,
        emailVerificationToken: null,
        emailVerificationExpires: null,
        updatedAt: new Date()
      })
      .eq('id', user.id);

    if (error) {
      throw new AppError(500, 'Failed to verify email', 'INTERNAL_SERVER_ERROR');
    }

    if (!user.email) {
      throw new AppError(500, 'User email not found', errorCodes.USER_NOT_FOUND);
    }

    await sendWelcomeEmail(user.email, user.firstName || '');
  } catch (error) {
    if (error instanceof AppError) throw error;
    throw new AppError(500, 'Failed to verify email', 'INTERNAL_SERVER_ERROR');
  }
}

export async function requestPasswordReset(email: string): Promise<void> {
  try {
    const { data: user, error: userError } = await supabase
      .from(usersTable)
      .select('*')
      .eq('email', email)
      .single();

    if (userError) {
      throw new AppError(404, 'User not found', errorCodes.NOT_FOUND);
    }

    if (!user) {
      throw new AppError(404, 'User not found', errorCodes.NOT_FOUND);
    }

    const resetToken = generateToken();
    const resetExpires = new Date(Date.now() + 60 * 60 * 1000); // 1 hour

    const { error } = await supabase
      .from(usersTable)
      .update({
        passwordResetToken: resetToken,
        passwordResetExpires: resetExpires,
        updatedAt: new Date()
      })
      .eq('id', user.id);

    if (error) {
      throw new AppError(500, 'Failed to request password reset', 'INTERNAL_SERVER_ERROR');
    }

    await sendPasswordResetEmail(email, resetToken);
  } catch (error) {
    if (error instanceof AppError) throw error;
    throw new AppError(500, 'Failed to request password reset', 'INTERNAL_SERVER_ERROR');
  }
}

export async function resetPassword(token: string, newPassword: string): Promise<void> {
  try {
    const { data: user, error: userError } = await supabase
      .from(usersTable)
      .select('*')
      .eq('passwordResetToken', token)
      .single();

    if (userError) {
      throw new AppError(400, 'Invalid or expired reset token', errorCodes.INVALID_TOKEN);
    }

    if (!user) {
      throw new AppError(400, 'Invalid or expired reset token', errorCodes.INVALID_TOKEN);
    }

    const hashedPassword = await hashPassword(newPassword);

    const { error } = await supabase
      .from(usersTable)
      .update({
        password: hashedPassword,
        passwordResetToken: null,
        passwordResetExpires: null,
        updatedAt: new Date()
      })
      .eq('id', user.id);

    if (error) {
      throw new AppError(500, 'Failed to reset password', 'INTERNAL_SERVER_ERROR');
    }
  } catch (error) {
    if (error instanceof AppError) throw error;
    throw new AppError(500, 'Failed to reset password', 'INTERNAL_SERVER_ERROR');
  }
}

export { sendVerificationEmail, NotificationService };
