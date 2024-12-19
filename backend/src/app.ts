import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import { JobScheduler } from './jobs/scheduler';
import config from './config';
import { logger } from './utils/logger';

// Import des routes
import orderRoutes from './routes/orders';
import zoneRoutes from './routes/zones';
import billingRoutes from './routes/billing';
import authRoutes from './routes/authRoutes';
import websocketRoutes from './routes/websocket';
import adminLogRoutes from './routes/adminLogRoutes';
import blogArticleRoutes from './routes/blogArticleRoutes'; 
import blogGeneratorRoutes from './routes/blogGeneratorRoutes';
import adminRoutes from './routes/adminRoutes';
import adminsRoutes from './routes/admins';
import affiliateRoutes from './routes/affiliateRoutes';
import analyticsRoutes from './routes/analytics';
import articlesRoutes from './routes/articles';
import authRouter from './routes/auth';
import categoriesRoutes from './routes/categories';
import deliveryTasksRoutes from './routes/delivery-tasks';
import deliveryRoutes from './routes/delivery';
import loyaltyRoutes from './routes/loyalty';
import notificationsRoutes from './routes/notifications';
import paymentsRoutes from './routes/payments';
import permissionRoutes from './routes/permissionRoutes';
import recurringOrdersRoutes from './routes/recurringOrders';
import subscriptionsRoutes from './routes/subscriptions';
import usersRoutes from './routes/users';

const app = express();

// Middleware de base
app.use(cors({
  origin: config.allowedOrigins,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  exposedHeaders: ['Content-Range', 'X-Content-Range'],
  credentials: true
}));
app.use(helmet({
  crossOriginEmbedderPolicy: false,
  crossOriginOpenerPolicy: false
}));
app.use(compression());
app.use(morgan('dev'));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/orders', orderRoutes);
app.use('/api/zones', zoneRoutes);
app.use('/api/billing', billingRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/websocket', websocketRoutes);
app.use('/api/adminLogs', adminLogRoutes);
app.use('/api/admin', adminRoutes); 
app.use('/api/blog', blogArticleRoutes); 
app.use('/api/blog-generator', blogGeneratorRoutes); 
app.use('/api/admins', adminsRoutes);
app.use('/api/affiliates', affiliateRoutes);
app.use('/api/analytics', analyticsRoutes);
app.use('/api/articles', articlesRoutes);
app.use('/api/auth', authRouter);
app.use('/api/categories', categoriesRoutes);
app.use('/api/delivery-tasks', deliveryTasksRoutes);
app.use('/api/delivery', deliveryRoutes);
app.use('/api/loyalty', loyaltyRoutes);
app.use('/api/notifications', notificationsRoutes);
app.use('/api/payments', paymentsRoutes);
app.use('/api/permissions', permissionRoutes);
app.use('/api/recurring-orders', recurringOrdersRoutes);
app.use('/api/subscriptions', subscriptionsRoutes);
app.use('/api/users', usersRoutes);

// Basic route for testing
app.get('/', (req, res) => {
  res.json({ message: 'Bienvenue sur l\'API du système de gestion de blanchisserie' });
});

// Gestion des erreurs 404
app.use((req, res) => {
  res.status(404).json({ 
    message: 'Route non trouvée', 
    status: 404 
  });
});

// Gestion des erreurs globales
app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
  logger.error(err.stack);
  res.status(500).json({ 
    message: 'Erreur interne du serveur', 
    status: 500 
  });
});

export default app;
