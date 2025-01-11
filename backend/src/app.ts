import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { createClient } from '@supabase/supabase-js';
import rateLimit from 'express-rate-limit';

// Import all routes
import authRoutes from './routes/auth.routes';
import orderRoutes from './routes/order.routes';
import deliveryRoutes from './routes/delivery.routes';
import affiliateRoutes from './routes/affiliate.routes';
import loyaltyRoutes from './routes/loyalty.routes';
import notificationRoutes from './routes/notification.routes';
import serviceRoutes from './routes/service.routes';
import addressRoutes from './routes/address.routes';
import adminRoutes from './routes/admin.routes';
import offerRoutes from './routes/offer.routes';
import articleCategoryRoutes from './routes/articleCategory.routes';
import articleRoutes from './routes/article.routes';
import articleServiceRoutes from './routes/articleService.routes';
import blogCategoryRoutes from './routes/blogCategory.routes';
import blogArticleRoutes from './routes/blogArticle.routes';
import orderItemRoutes from './routes/orderItem.routes';
import './scheduler'; // Importer le scheduler pour démarrer les tâches cron

// Load environment variables
dotenv.config();

const app = express();

// Middleware globaux
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use('/api', limiter);

// Routes
app.use('/api/auth', authRoutes); // Utiliser directement la route sans middleware

app.use('/api/orders', (req, res, next) => {
  console.log('Orders Routes Middleware:', req.user);
  orderRoutes(req, res, next);
});

app.use('/api/delivery', (req, res, next) => {
  console.log('Delivery Routes Middleware:', req.user);
  deliveryRoutes(req, res, next);
});

app.use('/api/affiliate', (req, res, next) => {
  console.log('Affiliate Routes Middleware:', req.user);
  affiliateRoutes(req, res, next);
});

app.use('/api/loyalty', (req, res, next) => {
  console.log('Loyalty Routes Middleware:', req.user);
  loyaltyRoutes(req, res, next);
});

app.use('/api/notifications', (req, res, next) => {
  console.log('Notifications Routes Middleware:', req.user);
  notificationRoutes(req, res, next);
});

app.use('/api/services', serviceRoutes);
app.use('/api/addresses', addressRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/offers', offerRoutes);
app.use('/api/article-categories', articleCategoryRoutes);
app.use('/api/articles', articleRoutes);
app.use('/api/article-services', articleServiceRoutes);
app.use('/api/blog-categories', blogCategoryRoutes);
app.use('/api/blog-articles', blogArticleRoutes);
app.use('/api/order-items', orderItemRoutes);

// Error handling middleware
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
});

// Initialize Supabase client
export const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_KEY!
);

// Basic route
app.get('/', (req, res) => {
  res.json({ message: 'Welcome to Alpha Laundry API' });
});

const PORT = process.env.PORT || 3001;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

export default app;
