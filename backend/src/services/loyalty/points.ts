import { db } from '../firebase';
import {
  LoyaltyAccount,
  LoyaltyTier,
  PointsTransaction,
} from '../../models/loyalty';
import { NotificationService } from '../notifications';

const loyaltyRef = db.collection('loyalty_accounts');
const pointsHistoryRef = db.collection('points_history');
const notificationService = new NotificationService();

export async function calculateTier(points: number): Promise<LoyaltyTier> {
  if (points >= 10001) return LoyaltyTier.PLATINUM;
  if (points >= 5001) return LoyaltyTier.GOLD;
  if (points >= 1001) return LoyaltyTier.SILVER;
  return LoyaltyTier.BRONZE;
}

export async function addPoints(userId: string, points: number, reason: string): Promise<LoyaltyAccount> {
  const accountRef = loyaltyRef.doc(userId);
  const account = await accountRef.get();

  let updatedAccount: LoyaltyAccount;

  await db.runTransaction(async (transaction) => {
    if (!account.exists) {
      updatedAccount = {
        userId,
        points: points,
        lifetimePoints: points,
        tier: await calculateTier(points),
        lastUpdated: new Date()
      };
      transaction.set(accountRef, updatedAccount);
    } else {
      const currentAccount = account.data() as LoyaltyAccount;
      const newPoints = currentAccount.points + points;
      const newLifetimePoints = currentAccount.lifetimePoints + points;
      const newTier = await calculateTier(newLifetimePoints);

      updatedAccount = {
        ...currentAccount,
        points: newPoints,
        lifetimePoints: newLifetimePoints,
        tier: newTier,
        lastUpdated: new Date()
      };
      transaction.update(accountRef, {
        points: updatedAccount.points,
        lifetimePoints: updatedAccount.lifetimePoints,
        tier: updatedAccount.tier,
        lastUpdated: updatedAccount.lastUpdated
      });
    }
  });

  // Send notification about points earned
  await notificationService.sendLoyaltyPointsReminder(userId, points);

  return updatedAccount!;
}

export async function getPointsHistory(
  userId: string,
  page: number = 1,
  limit: number = 10
): Promise<{ transactions: PointsTransaction[]; total: number }> {
  const offset = (page - 1) * limit;
  const query = pointsHistoryRef
    .where('userId', '==', userId)
    .orderBy('timestamp', 'desc')
    .limit(limit)
    .offset(offset);

  const [snapshot, countSnapshot] = await Promise.all([
    query.get(),
    pointsHistoryRef.where('userId', '==', userId).count().get()
  ]);

  return {
    transactions: snapshot.docs.map(doc => doc.data() as PointsTransaction),
    total: countSnapshot.data().count
  };
}

export async function getUserPoints(userId: string): Promise<number> {
  const doc = await loyaltyRef.doc(userId).get();
  const account = doc.exists ? (doc.data() as LoyaltyAccount) : null;
  return account ? account.points : 0;
}

export async function adjustUserPoints(userId: string, points: number, reason: string): Promise<LoyaltyAccount> {
  return addPoints(userId, points, reason);
}
