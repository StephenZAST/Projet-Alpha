import { collection, addDoc, Timestamp, getFirestore } from "firebase/firestore";
import { db } from "./firebase";
import { User } from "../models/user";
import { AppError, errorCodes } from '../utils/errors';
import * as admin from 'firebase-admin';
import * as crypto from 'crypto';
import * as bcrypt from 'bcrypt';
import { sendVerificationEmail, sendPasswordResetEmail } from './emailService';

enum UserRole {
  CLIENT,
  ADMIN
}

enum UserStatus {
  PENDING,
  ACTIVE
}

enum AccountCreationMethod {
  DIRECT,
  AFFILIATE_REFERRAL,
  CUSTOMER_REFERRAL
}

export async function createUser(user: User): Promise<User | null> {
  try {
    const firestore = getFirestore();
    const usersCollectionRef = collection(firestore, "users");
    const newUser = await addDoc(usersCollectionRef, {
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      address: user.address,
      role: user.role,
      affiliateId: user.affiliateId,
      creationDate: Timestamp.now(),
      lastLogin: Timestamp.now(),
    });
    const newUserData = { ...user, id: newUser.id };
    return newUserData;
  } catch (error) {
    console.error("Error creating user:", error);
    return null;
  }
}

export interface UserProfile {
  id: string;
  defaultAddress?: {
    formattedAddress: string;
    coordinates: {
      latitude: number;
      longitude: number;
    };
  };
  defaultItems?: any[];
  defaultInstructions?: string;
}

export async function getUserProfile(userId: string): Promise<UserProfile | null> {
  try {
    const userDoc = await db.collection('users').doc(userId).get();
    
    if (!userDoc.exists) {
      return null;
    }

    return {
      id: userDoc.id,
      ...userDoc.data()
    } as UserProfile;
  } catch (error) {
    console.error('Error fetching user profile:', error);
    throw new AppError(500, 'Failed to fetch user profile', errorCodes.DATABASE_ERROR);
  }
}

export async function registerCustomer(userData: Partial<User>, creationMethod: AccountCreationMethod): Promise<User> {
  const db = admin.firestore();
  const auth = admin.auth();

  // Generate verification token
  const verificationToken = crypto.randomBytes(32).toString('hex');
  const verificationExpires = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() + 24 * 60 * 60 * 1000) // 24 hours
  );

  // Hash password
  const hashedPassword = await bcrypt.hash(userData.password!, 10);

  // Create user data
  const newUser: User = {
    ...userData,
    uid: '', // Will be set after auth creation
    role: UserRole.CLIENT,
    status: UserStatus.PENDING,
    creationMethod,
    emailVerified: false,
    password: hashedPassword,
    verificationToken,
    verificationExpires,
    loyaltyPoints: 0,
    createdAt: admin.firestore.Timestamp.now(),
    updatedAt: admin.firestore.Timestamp.now()
  };

  try {
    // Start transaction
    const result = await db.runTransaction(async (transaction) => {
      // Check if affiliate code exists and is valid
      if (userData.affiliateCode) {
        const affiliateDoc = await transaction.get(
          db.collection('affiliates').where('code', '==', userData.affiliateCode).limit(1)
        );
        if (!affiliateDoc.empty) {
          newUser.affiliateId = affiliateDoc.docs[0].id;
          newUser.creationMethod = AccountCreationMethod.AFFILIATE_REFERRAL;
        }
      }

      // Check if sponsor code exists and is valid
      if (userData.sponsorCode) {
        const sponsorDoc = await transaction.get(
          db.collection('users').where('sponsorCode', '==', userData.sponsorCode).limit(1)
        );
        if (!sponsorDoc.empty) {
          newUser.sponsorId = sponsorDoc.docs[0].id;
          newUser.creationMethod = AccountCreationMethod.CUSTOMER_REFERRAL;
        }
      }

      // Create Firebase Auth user
      const userRecord = await auth.createUser({
        email: userData.email,
        password: userData.password, // Original password for auth
        displayName: userData.displayName,
        phoneNumber: userData.phoneNumber,
        disabled: false
      });

      // Set the generated UID
      newUser.uid = userRecord.uid;

      // Create user document
      const userRef = db.collection('users').doc(userRecord.uid);
      transaction.set(userRef, newUser);

      // Generate unique sponsor code for the new user
      const sponsorCode = await generateUniqueSponsorCode(transaction, db);
      transaction.update(userRef, { sponsorCode });

      return { ...newUser, sponsorCode };
    });

    // Send verification email
    await sendVerificationEmail(result.email, result.verificationToken);

    return result;
  } catch (error) {
    console.error('Error in registerCustomer:', error);
    throw new Error('Failed to register customer');
  }
}

async function generateUniqueSponsorCode(
  transaction: FirebaseFirestore.Transaction,
  db: FirebaseFirestore.Firestore
): Promise<string> {
  let code: string;
  let isUnique = false;

  while (!isUnique) {
    code = generateRandomCode(8); // Generate 8-character code
    const existingCode = await transaction.get(
      db.collection('users').where('sponsorCode', '==', code).limit(1)
    );
    if (existingCode.empty) {
      isUnique = true;
      return code;
    }
  }
  throw new Error('Failed to generate unique sponsor code');
}

function generateRandomCode(length: number): string {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * characters.length));
  }
  return result;
}

// Add these functions to handle email verification and password reset
export async function verifyEmail(token: string): Promise<void> {
  const db = admin.firestore();
  const userSnapshot = await db
    .collection('users')
    .where('verificationToken', '==', token)
    .where('verificationExpires', '>', admin.firestore.Timestamp.now())
    .limit(1)
    .get();

  if (userSnapshot.empty) {
    throw new Error('Invalid or expired verification token');
  }

  const userDoc = userSnapshot.docs[0];
  await db.runTransaction(async (transaction) => {
    transaction.update(userDoc.ref, {
      status: UserStatus.ACTIVE,
      emailVerified: true,
      verificationToken: null,
      verificationExpires: null,
      updatedAt: admin.firestore.Timestamp.now()
    });

    // Update Firebase Auth user
    await admin.auth().updateUser(userDoc.id, {
      emailVerified: true
    });
  });
}

export async function requestPasswordReset(email: string): Promise<void> {
  const db = admin.firestore();
  const userSnapshot = await db
    .collection('users')
    .where('email', '==', email)
    .limit(1)
    .get();

  if (userSnapshot.empty) {
    throw new Error('User not found');
  }

  const userDoc = userSnapshot.docs[0];
  const resetToken = crypto.randomBytes(32).toString('hex');
  const resetExpires = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() + 1 * 60 * 60 * 1000) // 1 hour
  );

  await userDoc.ref.update({
    passwordResetToken: resetToken,
    passwordResetExpires: resetExpires,
    updatedAt: admin.firestore.Timestamp.now()
  });

  await sendPasswordResetEmail(email, resetToken);
}

export async function resetPassword(token: string, newPassword: string): Promise<void> {
  const db = admin.firestore();
  const userSnapshot = await db
    .collection('users')
    .where('passwordResetToken', '==', token)
    .where('passwordResetExpires', '>', admin.firestore.Timestamp.now())
    .limit(1)
    .get();

  if (userSnapshot.empty) {
    throw new Error('Invalid or expired reset token');
  }

  const userDoc = userSnapshot.docs[0];
  const hashedPassword = await bcrypt.hash(newPassword, 10);

  await db.runTransaction(async (transaction) => {
    transaction.update(userDoc.ref, {
      password: hashedPassword,
      passwordResetToken: null,
      passwordResetExpires: null,
      updatedAt: admin.firestore.Timestamp.now()
    });

    // Update Firebase Auth user password
    await admin.auth().updateUser(userDoc.id, {
      password: newPassword
    });
  });
}
