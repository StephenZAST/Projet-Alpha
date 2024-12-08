const express = require('express');
const admin = require('firebase-admin');
const { AppError } = require('../../src/utils/errors');
const { db } = require('../../src/services/firebase'); // Assuming you have a firebase.ts file for database access
const { requireAdminRolePath } = require('../../src/middleware/auth');
const { UserRole } = require('../../src/models/user');

const router = express.Router();

// Middleware to check if the user is authenticated
const isAuthenticated = (req, res, next) => {
  const idToken = req.headers.authorization?.split('Bearer ')[1];

  if (!idToken) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  admin.auth().verifyIdToken(idToken)
      .then(decodedToken => {
        req.user = decodedToken;
        next();
      })
      .catch(error => {
        console.error('Error verifying ID token:', error);
        res.status(401).json({ error: 'Unauthorized' });
      });
};

// Apply authentication middleware to all routes
router.use(isAuthenticated);

// POST /api/billing
router.post('/', requireAdminRolePath([UserRole.SUPER_ADMIN]), async (req, res) => {
  try {
    const { orderId, items, totalAmount } = req.body;

    // Validate input data
    if (!orderId || !items || !totalAmount) {
      throw new AppError(400, 'Missing required fields', 'VALIDATION_ERROR');
    }

    // Create a new bill document in Firestore
    const billRef = await db.collection('bills').add({
      orderId,
      items,
      totalAmount,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      // Add other fields as needed (e.g., status, payment details)
    });

    res.status(201).json({ message: 'Bill created successfully', billId: billRef.id });
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error creating bill:', error);
    res.status(500).json({ error: 'Failed to create bill' });
  }
});

// GET /api/billing/{billId}
router.get('/:billId', async (req, res) => {
  try {
    const billId = req.params.billId;

    // Fetch the bill from Firestore
    const billDoc = await db.collection('bills').doc(billId).get();

    if (!billDoc.exists) {
      throw new AppError(404, 'Bill not found', 'BILL_NOT_FOUND');
    }

    const bill = billDoc.data();
    res.status(200).json({ bill });
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error fetching bill:', error);
    res.status(500).json({ error: 'Failed to fetch bill' });
  }
});

// GET /api/billing/user/{userId}
router.get('/user/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;

    // Fetch bills for the user from Firestore
    const billsSnapshot = await db.collection('bills').where('userId', '==', userId).get();

    if (billsSnapshot.empty) {
      return res.status(404).json({ error: 'No bills found for this user' });
    }

    const bills = billsSnapshot.docs.map(doc => doc.data());
    res.status(200).json({ bills });
  } catch (error) {
    console.error('Error fetching user bills:', error);
    res.status(500).json({ error: 'Failed to fetch user bills' });
  }
});

// GET /api/billing/loyalty/{userId}
router.get('/loyalty/:userId', async (req, res) => {
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
});

// POST /api/billing/loyalty/redeem
router.post('/loyalty/redeem', async (req, res) => {
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
});

// POST /api/billing/subscription
router.post('/subscription', async (req, res) => {
  try {
    const userId = req.user.uid;
    const { subscriptionType, paymentMethod } = req.body;

    // Validate input data
    if (!subscriptionType || !paymentMethod) {
      throw new AppError(400, 'Missing required fields: subscriptionType and paymentMethod', 'VALIDATION_ERROR');
    }

    // Fetch user document from Firestore
    const userDoc = await db.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      throw new AppError(404, 'User not found', 'USER_NOT_FOUND');
    }

    // Update user's subscription data
    await userDoc.ref.update({
      subscription: {
        type: subscriptionType,
        paymentMethod: paymentMethod,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        // Add other fields as needed (e.g., startDate, endDate)
      },
    });

    res.status(200).json({
      message: 'Subscription updated successfully',
      subscription: {
        type: subscriptionType,
        paymentMethod: paymentMethod,
      },
    });
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error updating subscription:', error);
    res.status(500).json({ error: 'Failed to update subscription' });
  }
});

// GET /api/billing/stats
router.get('/stats', requireAdminRole, async (req, res) => {
  try {
    const { startDate, endDate } = req.query;

    // Validate input data
    if (!startDate || !endDate) {
      throw new AppError(400, 'Missing required fields: startDate and endDate', 'VALIDATION_ERROR');
    }

    // Convert query parameters to Date objects
    const start = new Date(startDate);
    const end = new Date(endDate);

    // Fetch bills within the specified date range
    const billsSnapshot = await db.collection('bills')
        .where('createdAt', '>=', start)
        .where('createdAt', '<=', end)
        .get();

    let totalRevenue = 0;
    let totalOrders = 0;
    let subscriptionRevenue = 0;
    let loyaltyPointsIssued = 0;
    let loyaltyPointsRedeemed = 0;

    billsSnapshot.forEach(doc => {
      const billData = doc.data();
      totalRevenue += billData.totalAmount;
      totalOrders++;

      // Calculate subscription revenue (assuming you have a field for this)
      if (billData.subscription) {
        subscriptionRevenue += billData.subscription.amount;
      }

      // Calculate loyalty points issued and redeemed (assuming you have fields for these)
      loyaltyPointsIssued += billData.loyaltyPointsIssued || 0;
      loyaltyPointsRedeemed += billData.loyaltyPointsRedeemed || 0;
    });

    const averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;

    res.status(200).json({
      stats: {
        totalRevenue,
        totalOrders,
        averageOrderValue,
        subscriptionRevenue,
        loyaltyPointsIssued,
        loyaltyPointsRedeemed,
      },
    });
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error fetching billing stats:', error);
    res.status(500).json({ error: 'Failed to fetch billing stats' });
  }
});

// POST /api/billing/offers
router.post('/offers', requireAdminRole, async (req, res) => {
  try {
    const { name, description, discountType, discountValue, startDate, endDate } = req.body;

    // Validate input data
    if (!name || !description || !discountType || !discountValue || !startDate || !endDate) {
      throw new AppError(400, 'Missing required fields', 'VALIDATION_ERROR');
    }

    // Create a new offer document in Firestore
    const offerRef = await db.collection('offers').add({
      name,
      description,
      discountType,
      discountValue,
      startDate: new Date(startDate),
      endDate: new Date(endDate),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      // Add other fields as needed (e.g., status, usage limits)
    });

    res.status(201).json({
      message: 'Special offer created successfully',
      offer: {
        id: offerRef.id,
        name,
        description,
        discountType,
        discountValue,
        startDate,
        endDate, // Add missing comma
      },
    });
  } catch (error) {
    if (error instanceof AppError) {
      return res.status(error.statusCode).json({ error: error.message });
    }
    console.error('Error creating special offer:', error);
    res.status(500).json({ error: 'Failed to create special offer' });
  }
});

module.exports = router;
