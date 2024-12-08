const express = require('express');
const admin = require('firebase-admin');
const { AppError } = require('../../src/utils/errors');
const { db } = require('../../src/services/firebase'); // Assuming you have a firebase.ts file for database access
const { requireAdminRolePath } = require('../../src/middleware/auth');
const { UserRole } = require('../../src/models/user');

const router = express.Router();

// Import modular code
const billing = require('./billing');
const loyalty = require('./loyalty');
const subscription = require('./subscription');
const stats = require('./stats');

// Apply authentication middleware to all routes
router.use(requireAdminRolePath([UserRole.SUPER_ADMIN]));

// Use modular code
router.post('/billing', billing.createBill);
router.get('/billing/:billId', billing.getBill);
router.get('/billing/user/:userId', billing.getBillsForUser);
router.get('/billing/loyalty/:userId', loyalty.getLoyaltyPoints);
router.post('/billing/loyalty/redeem', loyalty.redeemPoints);
router.post('/billing/subscription', subscription.updateSubscription);
router.get('/billing/stats', stats.getStats);

module.exports = router;
