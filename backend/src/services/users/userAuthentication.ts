import { db } from '../../config/firebase';
import { User } from '../../models/user';
import { hash } from 'bcrypt';
import { generateToken } from '../../utils/tokens';
import { sendVerificationEmail, sendPasswordResetEmail, sendWelcomeEmail } from '../emailService';

const SALT_ROUNDS = 10;
const USERS_COLLECTION = 'users';

export async function verifyEmail(token: string): Promise<void> {
  const userSnapshot = await db.collection(USERS_COLLECTION)
    .where('emailVerificationToken', '==', token)
    .where('emailVerificationExpires', '>', new Date())
    .limit(1)
    .get();

  if (userSnapshot.empty) {
    throw new Error('Invalid or expired verification token');
  }

  const userDoc = userSnapshot.docs[0];
  const user = userDoc.data() as User;

  await userDoc.ref.update({
    emailVerified: true,
    status: 'active',
    emailVerificationToken: null,
    emailVerificationExpires: null,
    updatedAt: new Date()
  });

  await sendWelcomeEmail(user.profile.email, user.profile.firstName);
}

export async function requestPasswordReset(email: string): Promise<void> {
  const user = await getUserByEmail(email);
  if (!user) {
    throw new Error('User not found');
  }

  const resetToken = generateToken();
  const resetExpires = new Date(Date.now() + 60 * 60 * 1000); // 1 hour

  await db.collection(USERS_COLLECTION).doc(user.id).update({
    passwordResetToken: resetToken,
    passwordResetExpires: resetExpires,
    updatedAt: new Date()
  });

  await sendPasswordResetEmail(email, resetToken);
}

export async function resetPassword(token: string, newPassword: string): Promise<void> {
  const userSnapshot = await db.collection(USERS_COLLECTION)
    .where('passwordResetToken', '==', token)
    .where('passwordResetExpires', '>', new Date())
    .limit(1)
    .get();

  if (userSnapshot.empty) {
    throw new Error('Invalid or expired reset token');
  }

  const hashedPassword = await hash(newPassword, SALT_ROUNDS);

  await userSnapshot.docs[0].ref.update({
    password: hashedPassword,
    passwordResetToken: null,
    passwordResetExpires: null,
    updatedAt: new Date()
  });
}

async function getUserByEmail(email: string): Promise<User | null> {
  const userSnapshot = await db.collection(USERS_COLLECTION)
    .where('profile.email', '==', email)
    .limit(1)
    .get();

  if (userSnapshot.empty) {
    return null;
  }

  const userData = userSnapshot.docs[0].data() as User;
  return {
    ...userData
  };
}
