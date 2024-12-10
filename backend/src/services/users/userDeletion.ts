import { db, auth } from '../../config/firebase';
import { UserStatus } from '../../models/user';

const USERS_COLLECTION = 'users';

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
