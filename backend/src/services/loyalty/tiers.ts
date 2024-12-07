import { db } from '../firebase';
import { LoyaltyTierConfig } from '../../models/loyalty';
import { AppError, errorCodes } from '../../utils/errors';

const tiersRef = db.collection('loyalty_tiers');

export async function updateLoyaltyTier(
  tierId: string,
  tierData: Partial<LoyaltyTierConfig>
): Promise<LoyaltyTierConfig> {
  const tierRef = tiersRef.doc(tierId);
  const doc = await tierRef.get();

  if (!doc.exists) {
    throw new AppError(404, 'Tier not found', errorCodes.NOT_FOUND);
  }

  const { pointsThreshold, name, benefits } = tierData;

  await tierRef.update({
    pointsThreshold,
    name,
    benefits,
    updatedAt: new Date()
  });

  return {
    ...doc.data(),
    ...tierData,
    updatedAt: new Date()
  } as LoyaltyTierConfig;
}

export async function getLoyaltyTiers(): Promise<LoyaltyTierConfig[]> {
  const snapshot = await tiersRef.orderBy('pointsThreshold', 'asc').get();
  return snapshot.docs.map(doc => ({
    id: doc.id,
    ...doc.data()
  } as LoyaltyTierConfig));
}
