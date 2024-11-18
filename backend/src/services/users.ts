import { db, auth } from '../config/firebase';
import { User, UserRole, UserStatus, AccountCreationMethod, CreateUserInput } from '../models/user';
import { hash } from 'bcrypt';
import { generateToken } from '../utils/tokens';
import { sendVerificationEmail, sendPasswordResetEmail, sendWelcomeEmail } from './emailService';

const SALT_ROUNDS = 10;
const USERS_COLLECTION = 'users';

export async function createUser(userData: CreateUserInput): Promise<User> {
  try {
    const userRef = db.collection(USERS_COLLECTION).doc();
    const now = new Date();
    
    // Create Firebase Auth user if not exists
    let firebaseUser;
    if (!userData.uid) {
      firebaseUser = await auth.createUser({
        email: userData.email,
        password: userData.password,
        displayName: `${userData.firstName} ${userData.lastName}`,
        phoneNumber: userData.phoneNumber
      });
    }

    const hashedPassword = await hash(userData.password, SALT_ROUNDS);
    
    const newUser: User = {
      id: userRef.id,
      uid: userData.uid || firebaseUser?.uid || userRef.id,
      email: userData.email,
      password: hashedPassword,
      firstName: userData.firstName,
      lastName: userData.lastName,
      displayName: userData.displayName || `${userData.firstName} ${userData.lastName}`,
      phoneNumber: userData.phoneNumber,
      role: userData.role || UserRole.CLIENT,
      status: UserStatus.PENDING,
      creationMethod: userData.creationMethod || AccountCreationMethod.SELF_REGISTRATION,
      emailVerified: false,
      loyaltyPoints: 0,
      defaultItems: [],
      defaultInstructions: '',
      createdAt: now,
      updatedAt: now
    };

    await userRef.set(newUser);

    // Send verification email
    const verificationToken = await generateToken();
    await sendVerificationEmail(newUser.email, verificationToken);

    return newUser;
  } catch (error) {
    console.error('Error creating user:', error);
    throw error;
  }
}

export async function registerCustomer(
  userData: CreateUserInput,
  method: AccountCreationMethod
): Promise<User> {
  const existingUser = await getUserByEmail(userData.email);
  if (existingUser) {
    throw new Error('Email already registered');
  }

  return createUser({
    ...userData,
    role: UserRole.CLIENT,
    status: UserStatus.PENDING,
    creationMethod: method
  });
}

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
    status: UserStatus.ACTIVE,
    emailVerificationToken: null,
    emailVerificationExpires: null,
    updatedAt: new Date()
  });

  await sendWelcomeEmail(user.email, user.firstName);
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

export async function getUserByEmail(email: string): Promise<User | null> {
  const userSnapshot = await db.collection(USERS_COLLECTION)
    .where('email', '==', email)
    .limit(1)
    .get();

  if (userSnapshot.empty) {
    return null;
  }

  const userData = userSnapshot.docs[0].data() as User;
  return {
    ...userData,
    id: userSnapshot.docs[0].id
  };
}

export async function getUserById(id: string): Promise<User | null> {
  const userDoc = await db.collection(USERS_COLLECTION).doc(id).get();
  
  if (!userDoc.exists) {
    return null;
  }

  const userData = userDoc.data() as User;
  return {
    ...userData,
    id: userDoc.id
  };
}

export async function getUserProfile(uid: string): Promise<User | null> {
  try {
    const userSnapshot = await db.collection(USERS_COLLECTION)
      .where('uid', '==', uid)
      .limit(1)
      .get();
    
    if (userSnapshot.empty) {
      return null;
    }

    const userData = userSnapshot.docs[0].data() as User;
    return {
      ...userData,
      id: userSnapshot.docs[0].id
    };
  } catch (error) {
    console.error('Error getting user profile:', error);
    throw error;
  }
}

export async function updateUser(uid: string, updates: Partial<User>): Promise<User> {
  try {
    const userRef = db.collection(USERS_COLLECTION)
      .where('uid', '==', uid)
      .limit(1);
    const userSnapshot = await userRef.get();
    
    if (userSnapshot.empty) {
      throw new Error('User not found');
    }

    const userDoc = userSnapshot.docs[0];
    const updatedUser = {
      ...userDoc.data(),
      ...updates,
      updatedAt: new Date()
    } as User;

    await userDoc.ref.update(updatedUser);
    return updatedUser;
  } catch (error) {
    console.error('Error updating user:', error);
    throw error;
  }
}

export async function deleteUser(uid: string): Promise<void> {
  try {
    const userRef = db.collection(USERS_COLLECTION)
      .where('uid', '==', uid)
      .limit(1);
    const userSnapshot = await userRef.get();
    
    if (userSnapshot.empty) {
      throw new Error('User not found');
    }

    await userSnapshot.docs[0].ref.update({
      status: UserStatus.DELETED,
      updatedAt: new Date()
    });

    // Delete from Firebase Auth
    try {
      await auth.deleteUser(uid);
    } catch (error) {
      console.error('Error deleting Firebase Auth user:', error);
    }
  } catch (error) {
    console.error('Error deleting user:', error);
    throw error;
  }
}

export { sendVerificationEmail };
