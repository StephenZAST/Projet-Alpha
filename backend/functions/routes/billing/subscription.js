const { db } = require('../../../../src/services/firebase');
const { AppError } = require('../../../../src/utils/errors');
const admin = require('firebase-admin');

const updateSubscription = async (req, res) => {
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
};

module.exports = { updateSubscription };
