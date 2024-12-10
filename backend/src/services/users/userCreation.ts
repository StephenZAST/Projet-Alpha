import { db, auth } from '../../config/firebase';
import { User, UserRole, UserStatus, AccountCreationMethod, CreateUserInput } from '../../models/user';
import { hash } from 'bcrypt';
import { generateToken } from '../../utils/tokens';
import { sendVerificationEmail } from '../emailService';
import { Timestamp } from 'firebase/firestore';

const SALT_ROUNDS = 10;
const USERS_COLLECTION = 'users';

export async function createUser(userData: CreateUserInput): Promise<User> {
  try {
    const userRef = db.collection(USERS_COLLECTION).doc();
    const now = Timestamp.now();

    // Create Firebase Auth user if not exists
    let firebaseUser;
    if (!userData.uid) {
      firebaseUser = await auth.createUser({
        email: userData.profile.email,
        password: userData.password!,
        displayName: `${userData.profile.firstName} ${userData.profile.lastName}`,
        phoneNumber: userData.profile.phoneNumber
      });
    }

    const hashedPassword = await hash(userData.password!, SALT_ROUNDS);

    const newUser: User = {
      id: userRef.id,
      uid: userData.uid || firebaseUser?.uid || userRef.id,
      profile: {
        ...userData.profile,
        lastUpdated: now,
        preferences: undefined
      },
      role: userData.role || UserRole.CLIENT,
      status: UserStatus.PENDING,
      creationMethod: userData.creationMethod || AccountCreationMethod.SELF_REGISTRATION,
      emailVerified: false,
      loyaltyPoints: 0,
      createdAt: now,
      updatedAt: now,
      phoneNumber: undefined,
      displayName: undefined,
      email: undefined,
      lastName: undefined,
      firstName: undefined
    };

    await userRef.set(newUser);

    // Send verification email
    const verificationToken = await generateToken();
    await sendVerificationEmail(newUser.profile.email, verificationToken);

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
  const existingUser = await getUserByEmail(userData.profile.email);
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
