import { db } from '../firebase';
import { Reward } from '../../models/loyalty';

const rewardsRef = db.collection('rewards');

export async function createReward(rewardData: Partial<Reward>): Promise<Reward> {
  const reward: Reward = {
    ...rewardData,
    createdAt: new Date(),
    isActive: true,
    redemptionCount: 0
  } as Reward;

  const rewardRef = rewardsRef.doc();
  await rewardRef.set(reward);

  return {
    ...reward
  };
}

export async function updateReward(rewardId: string, rewardData: Partial<Reward>): Promise<Reward> {
  const rewardRef = rewardsRef.doc(rewardId);
  await rewardRef.update(rewardData);
  const updatedReward = await rewardRef.get();

  return {
    id: updatedReward.id,
    ...updatedReward.data(),
  } as Reward;
}

export async function deleteReward(rewardId: string): Promise<void> {
  const rewardRef = rewardsRef.doc(rewardId);
  await rewardRef.delete();
}

export async function getRewards(options: {
  page?: number;
  limit?: number;
  status?: string;
  startDate?: Date;
  endDate?: Date;
}): Promise<{ rewards: Reward[]; total: number }> {
  const {
    page = 1,
    limit = 10,
    status,
    startDate,
    endDate
  } = options;

  let query = rewardsRef.orderBy('createdAt', 'desc');

  if (status) {
    query = query.where('status', '==', status);
  }

  if (startDate) {
    query = query.where('createdAt', '>=', startDate);
  }

  if (endDate) {
    query = query.where('createdAt', '<=', endDate);
  }

  const offset = (page - 1) * limit;
  query = query.limit(limit).offset(offset);

  const [snapshot, countSnapshot] = await Promise.all([
    query.get(),
    rewardsRef.count().get()
  ]);

  return {
    rewards: snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Reward)),
    total: countSnapshot.data().count
  };
}

export async function getRewardById(rewardId: string): Promise<Reward | null> {
  const rewardRef = rewardsRef.doc(rewardId);
  const rewardSnapshot = await rewardRef.get();

  if (!rewardSnapshot.exists) {
    return null;
  }

  return { id: rewardSnapshot.id, ...rewardSnapshot.data() } as Reward;
}

export async function getAvailableRewards(userId: string, p0: { type: string; category: string; status: string; }): Promise<Reward[]> {
    const loyaltyRef = db.collection('loyalty_accounts');
    const accountDoc = await loyaltyRef.doc(userId).get();
    if (!accountDoc.exists) {
      return [];
    }

    const account = accountDoc.data() as { points: number };
    const rewardsSnapshot = await rewardsRef
      .where('isActive', '==', true)
      .where('pointsCost', '<=', account.points)
      .get();

    return rewardsSnapshot.docs.map(doc => ({
      ...doc.data()
    } as Reward));
  }
