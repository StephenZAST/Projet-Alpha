/* eslint-disable no-unused-vars */
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

// Import and use the categories routes
const categoriesRoutes = require('./routes/categories');
app.use('/categories', categoriesRoutes);

// Import and use the delivery-tasks routes
const deliveryTasksRoutes = require('./routes/delivery-tasks');
app.use('/delivery-tasks', deliveryTasksRoutes);

// Import and use the delivery routes
const deliveryRoutes = require('./routes/delivery');
app.use('/delivery', deliveryRoutes);

// Import and use the loyalty routes
const loyaltyRoutes = require('./routes/loyalty');
app.use('/loyalty', loyaltyRoutes);

// Import and use the notifications routes
const notificationsRoutes = require('./routes/notifications');
app.use('/notifications', notificationsRoutes);

// Import and use the orders routes
const ordersRoutes = require('./routes/orders');
app.use('/orders', ordersRoutes);

// Import and use the payments routes
const paymentsRoutes = require('./routes/payments');
app.use('/payments', paymentsRoutes);

// Import and use the permissions routes
const permissionsRoutes = require('./routes/permissions');
app.use('/permissions', permissionsRoutes);

// Import and use the recurringOrders routes
const recurringOrdersRoutes = require('./routes/recurringOrders');
app.use('/recurringOrders', recurringOrdersRoutes);

// Import and use the subscriptions routes
const subscriptionsRoutes = require('./routes/subscriptions');
app.use('/subscriptions', subscriptionsRoutes);

// Import and use the users routes
const usersRoutes = require('./routes/users');
app.use('/users', usersRoutes);

exports.api = functions.https.onRequest(app);
