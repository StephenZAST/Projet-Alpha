const { db } = require('../../../../src/services/firebase');
const { AppError } = require('../../../../src/utils/errors');
const admin = require('firebase-admin');

const getStats = async (req, res) => {
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
};

module.exports = { getStats };
