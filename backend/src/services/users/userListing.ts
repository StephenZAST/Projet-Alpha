import { db } from '../../config/firebase';
import { User } from '../../models/user';
import { AppError, errorCodes } from '../../utils/errors';

const USERS_COLLECTION = 'users';

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
