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
import archiveRoutes from './routes/archive.routes';
import subscriptionRoutes from './routes/subscription.routes';
import weightPricingRoutes from './routes/weightPricing.routes';
import serviceTypeRoutes from './routes/serviceType.routes';
import userRoutes from './routes/user.routes';
import './scheduler'; // Importer le scheduler pour démarrer les tâches cron

// Load environment variables
dotenv.config();

const app = express();
 
// Middleware globaux
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Configure CORS 
const allowedOrigins = [
  'http://localhost:3000',   // React default
  'http://localhost:3001',   // Your API
  'http://127.0.0.1:3000',
  'http://127.0.0.1:3001',
  'http://localhost:8080',   // Common dev port
  'http://localhost:8081',   // Common dev port
  'http://localhost:53492',  // Flutter web debug
  'http://localhost:51284',  // Flutter web debug
  'http://localhost:61846',  // Flutter web debug
  /^http:\/\/localhost:\d+$/, // Any localhost port
  /^http:\/\/127\.0\.0\.1:\d+$/ // Any 127.0.0.1 port
];

app.use(cors({
  origin: (origin, callback) => {
    if (!origin) return callback(null, true);
    
    if (
      allowedOrigins.some(allowedOrigin => {
        if (allowedOrigin instanceof RegExp) {
          return allowedOrigin.test(origin);
        }
        return allowedOrigin === origin;
      })
    ) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
}));

// Rate limiting configuration
const loginLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 heure
  max: 20, // 20 tentatives par heure
  message: { message: 'Trop de tentatives de connexion, veuillez réessayer plus tard.' },
  standardHeaders: true,
  legacyHeaders: false,
});

const adminLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5000, // limite élevée
  standardHeaders: true,
  legacyHeaders: false,
});

const standardLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10000, // limite standard
  standardHeaders: true,
  legacyHeaders: false,
});

// Appliquer les limites par route
app.use('/api/auth/admin/login', loginLimiter);
app.use('/api/admin', adminLimiter);
app.use('/api/orders', adminLimiter);
app.use('/api/notifications', adminLimiter);
app.use('/api', standardLimiter);

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/delivery', deliveryRoutes);
app.use('/api/affiliate', affiliateRoutes);
app.use('/api/loyalty', loyaltyRoutes);
app.use('/api/notifications', notificationRoutes);
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
app.use('/api/archives', archiveRoutes);
app.use('/api/subscriptions', subscriptionRoutes);
app.use('/api/weight-pricing', weightPricingRoutes);
app.use('/api/service-types', serviceTypeRoutes); 
app.use('/api/users', userRoutes);

// Ajouter la route health check
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    message: 'Server is running'
  });
});

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
