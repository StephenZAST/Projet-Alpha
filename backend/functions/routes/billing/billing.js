const { db } = require('../../../../src/services/firebase');
const { AppError } = require('../../../../src/utils/errors');
const admin = require('firebase-admin');

const createBill = async (req, res) => {
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
};

const getBill = async (req, res) => {
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
};

const getBillsForUser = async (req, res) => {
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
};

module.exports = { createBill, getBill, getBillsForUser };
