import { db } from '../../config/firebase';
import { User, UserProfile } from '../../models/user';
import { AppError, errorCodes } from '../../utils/errors';

const USERS_COLLECTION = 'users';

export async function getUserByEmail(email: string): Promise<User | null> {
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

export async function getUserById(id: string): Promise<User | null> {
  const userDoc = await db.collection(USERS_COLLECTION).doc(id).get();

  if (!userDoc.exists) {
    return null;
  }

  const userData = userDoc.data() as User;
  return {
    ...userData
  };
}

export async function getUserProfile(userId: string): Promise<UserProfile> {
  try {
    const userDoc = await db.collection(USERS_COLLECTION).doc(userId).get();

    if (!userDoc.exists) {
      throw new AppError(404, 'User not found', errorCodes.USER_NOT_FOUND);
    }

    const userData = userDoc.data() as User;
    return {
      ...userData.profile,
      lastUpdated: userData.updatedAt
    };
  } catch (error) {
    if (error instanceof AppError) throw error;
    throw new AppError(500, 'Failed to fetch user', errorCodes.DATABASE_ERROR);
  }
}

export async function getUserProfileByUid(uid: string): Promise<User | null> {
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
      ...userData
    };
  } catch (error) {
    console.error('Error getting user profile:', error);
    throw error;
  }
}
