import { db, CollectionReference } from '../../config/firebase';
import { User, UserProfile } from '../../models/user';
import { AppError, errorCodes } from '../../utils/errors';

const USERS_COLLECTION = 'users';

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
    throw new AppError(500, 'Failed to fetch user profile', errorCodes.DATABASE_ERROR);
  }
}

export async function getUserById(userId: string): Promise<User | null> {
  const userDoc = await db.collection(USERS_COLLECTION).doc(userId).get();

  if (!userDoc.exists) {
    return null;
  }

  const userData = userDoc.data() as User;
  return {
    ...userData
  };
}

export async function getUsers({ page = 1, limit = 10, search = '' }): Promise<{ users: User[], total: number, page: number, totalPages: number }> {
  try {
    const totalDocs = await db.collection(USERS_COLLECTION).count().get();
    const total = totalDocs.data().count;
    const totalPages = Math.ceil(total / limit);

    let snapshot = db.collection(USERS_COLLECTION)
      .orderBy('createdAt', 'desc')
      .offset((page - 1) * limit)
      .limit(limit);

    if (search) {
      snapshot = snapshot.where('profile.displayName', '>=', search)
        .where('profile.displayName', '<=', search + '\uf8ff');
    }

    const users = (await snapshot.get()).docs.map(doc => ({
      ...(doc.data() as User)
    }));

    return {
      users,
      total,
      page,
      totalPages
    };
  } catch (error) {
    throw new AppError(500, 'Failed to fetch users', errorCodes.DATABASE_ERROR);
  }
}

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
