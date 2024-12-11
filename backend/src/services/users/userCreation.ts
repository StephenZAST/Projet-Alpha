import { db, auth, CollectionReference, Timestamp } from '../../config/firebase';
import { User, UserRole, UserStatus, AccountCreationMethod, CreateUserInput, UserProfile, UserAddress, UserPreferences } from '../../models/user';
import { hash } from 'bcrypt';
import { generateToken } from '../../utils/tokens';
import { sendVerificationEmail } from '../users/userVerification';
import { AppError, errorCodes } from '../../utils/errors';
import { getUserByEmail } from '../users/userRetrieval';

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
        password: userData.password,
        displayName: `${userData.profile.firstName} ${userData.profile.lastName}`,
        phoneNumber: userData.profile.phoneNumber
      });
    }

    const hashedPassword = await hash(userData.password, SALT_ROUNDS);

    const newUser: User = {
      id: userRef.id,
      uid: userData.uid || firebaseUser?.uid || userRef.id,
      profile: {
        ...userData.profile,
        address: null,
        defaultInstructions: '',
        defaultItems: [],
        lastUpdated: now,
        preferences: {
          notifications: false,
          defaultItems: [],
          defaultInstructions: ''
        }
      },
      role: userData.role || UserRole.CLIENT,
      status: UserStatus.PENDING,
      creationMethod: userData.creationMethod || AccountCreationMethod.SELF_REGISTRATION,
      emailVerified: false,
      loyaltyPoints: 0,
      defaultItems: [],
      defaultInstructions: '',
      createdAt: now,
      updatedAt: now,
      phoneNumber: null,
      displayName: null,
      email: null,
      lastName: null,
      firstName: null
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

export { getUserByEmail };
