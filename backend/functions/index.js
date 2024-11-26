const functions = require('firebase-functions');
const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');

admin.initializeApp();
const db = admin.firestore();
const auth = admin.auth();

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// Import and use the auth routes
const authRoutes = require('./routes/auth');
app.use('/auth', authRoutes);

// Import and use the teams routes
const teamsRoutes = require('./routes/teams');
app.use('/teams', teamsRoutes);

// Import and use the admins routes
const adminsRoutes = require('./routes/admins');
app.use('/admins', adminsRoutes);

// Import and use the admin logs routes
const adminLogsRoutes = require('./routes/adminLogs');
app.use('/adminLogs', adminLogsRoutes);

// Import and use the affiliate routes
const affiliateRoutes = require('./routes/affiliates');
app.use('/affiliates', affiliateRoutes);

// Import and use the analytics routes
const analyticsRoutes = require('./routes/analytics');
app.use('/analytics', analyticsRoutes);

// Import and use the articles routes
const articlesRoutes = require('./routes/articles');
app.use('/articles', articlesRoutes);

// Import and use the billing routes
const billingRoutes = require('./routes/billing');
app.use('/billing', billingRoutes);

exports.api = functions.https.onRequest(app);
