const functions = require('firebase-functions');
const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');

const {
  errorHandler,
  unhandledRejectionHandler,
  notFoundHandler,
} = require('./middleware/errorHandler');

admin.initializeApp();
const db = admin.firestore();
const auth = admin.auth();

const app = express();

// Middleware de base
app.use(cors({ origin: true }));
app.use(helmet());
app.use(compression());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Import des routes
const authRoutes = require('./routes/auth');
const teamsRoutes = require('./routes/teams');
const adminsRoutes = require('./routes/admins');
const adminLogsRoutes = require('./routes/adminLogs');
const affiliateRoutes = require('./routes/affiliates');
const analyticsRoutes = require('./routes/analytics');
const articlesRoutes = require('./routes/articles');
const billingRoutes = require('./routes/billing');
const categoriesRoutes = require('./routes/categories');
const deliveryTasksRoutes = require('./routes/delivery-tasks');
const deliveryRoutes = require('./routes/delivery');
const loyaltyRoutes = require('./routes/loyalty');
const notificationsRoutes = require('./routes/notifications');
const ordersRoutes = require('./routes/orders');
const paymentsRoutes = require('./routes/payments');
const permissionsRoutes = require('./routes/permissions');
const recurringOrdersRoutes = require('./routes/recurringOrders');
const subscriptionsRoutes = require('./routes/subscriptions');
const usersRoutes = require('./routes/users');
const zonesRoutes = require('./routes/zones');
const blogArticleRoutes = require('./routes/blogArticle');
const blogGeneratorRoutes = require('./routes/blogGenerator');

// Utilisation des routes
app.use('/auth', authRoutes);
app.use('/teams', teamsRoutes);
app.use('/admins', adminsRoutes);
app.use('/adminLogs', adminLogsRoutes);
app.use('/affiliates', affiliateRoutes);
app.use('/analytics', analyticsRoutes);
app.use('/articles', articlesRoutes);
app.use('/billing', billingRoutes);
app.use('/categories', categoriesRoutes);
app.use('/delivery-tasks', deliveryTasksRoutes);
app.use('/delivery', deliveryRoutes);
app.use('/loyalty', loyaltyRoutes);
app.use('/notifications', notificationsRoutes);
app.use('/orders', ordersRoutes);
app.use('/payments', paymentsRoutes);
app.use('/permissions', permissionsRoutes);
app.use('/recurring-orders', recurringOrdersRoutes);
app.use('/subscriptions', subscriptionsRoutes);
app.use('/users', usersRoutes);
app.use('/zones', zonesRoutes);
app.use('/blog', blogArticleRoutes);
app.use('/blog-generator', blogGeneratorRoutes);

// Route de base
app.get('/', (req, res) => {
  res.json({
    message: 'Bienvenue sur l\'API du système de gestion de blanchisserie',
    version: '2.0.0',
  });
});

// Gestion des erreurs
app.use(notFoundHandler);
app.use(errorHandler);
app.use(unhandledRejectionHandler);

// Export de la fonction
exports.api = functions.region('europe-west1').https.onRequest(app);
