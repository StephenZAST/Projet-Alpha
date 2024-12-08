const { db } = require('../../../../src/services/firebase');
const { AppError } = require('../../../../src/utils/errors');
const admin = require('firebase-admin');

const getLoyaltyPoints = async (req, res) => {
  try {
    const userId = req.params.userId;

    // Fetch user's loyalty data from Firestore
    const userDoc = await db.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      throw new AppError(404, 'User not found', 'USER_NOT_FOUND');
    }

    const userData = userDoc.data();
    const loyaltyPoints = userData?.loyaltyPoints || 0;

    // Fetch loyalty history (assuming you have a separate collection for this)
    const historySnapshot = await db.collection('loyalty_history')
        .where('userId', '==', userId)
        .orderBy('date', 'desc')
        .get();

    const history = historySnapshot.docs.map(doc => doc.data());

    // Fetch available rewards (assuming you have a separate collection for this)
    const rewardsSnapshot = await db.collection('rewards').get();
    const availableRewards = rewardsSnapshot.docs
        .map(doc => doc.data())
        .filter(reward => reward.points <= loyaltyPoints);

    res.status(200).json({ loyaltyPoints, history, availableRewards });
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error fetching loyalty points:', error);
    res.status(500).json({ error: 'Failed to fetch loyalty points' });
  }
};

const redeemPoints = async (req, res) => {
  try {
    const userId = req.user.uid;
    const { rewardId, points } = req.body;

    // Validate input data
    if (!rewardId || !points) {
      throw new AppError(400, 'Missing required fields: rewardId and points', 'VALIDATION_ERROR');
    }

    // Fetch user's loyalty data from Firestore
    const userDoc = await db.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      throw new AppError(404, 'User not found', 'USER_NOT_FOUND');
    }

    const userData = userDoc.data();
    let loyaltyPoints = userData?.loyaltyPoints || 0;

    // Fetch reward details from Firestore
    const rewardDoc = await db.collection('rewards').doc(rewardId).get();

    if (!rewardDoc.exists) {
      throw new AppError(404, 'Reward not found', 'REWARD_NOT_FOUND');
    }

    const rewardData = rewardDoc.data();

    // Check if the user has enough points
    if (loyaltyPoints < rewardData.points) {
      throw new AppError(400, 'Insufficient loyalty points', 'INSUFFICIENT_POINTS');
    }

    // Deduct points and update user's loyalty points
    loyaltyPoints -= rewardData.points;
    await userDoc.ref.update({ loyaltyPoints });

    // Record the redemption (assuming you have a 'redemptions' collection)
    await db.collection('redemptions').add({
      userId,
      rewardId,
      points: rewardData.points,
      redeemedAt: admin.firestore.FieldValue.serverTimestamp(),
      // Add other fields as needed (e.g., reward name, status)
    });

    res.status(200).json({
      message: 'Points redeemed successfully',
      remainingPoints: loyaltyPoints,
      reward: {
        name: rewardData.name,
        points: rewardData.points,
      },
    });
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error redeeming points:', error);
    res.status(500).json({ error: 'Failed to redeem points' });
  }
};

module.exports = { getLoyaltyPoints, redeemPoints };
