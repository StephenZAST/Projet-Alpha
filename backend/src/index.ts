import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import usersRouter from './routes/users';
import ordersRouter from './routes/orders';
import articlesRouter from './routes/articles';
import notificationsRouter from './routes/notifications';
import categoriesRouter from './routes/categories';
import subscriptionsRouter from './routes/subscriptions';
import adminRouter from './routes/admins';  
import authRouter from './routes/auth';     
import { config } from './config';
import { AppError } from './utils/errors';

const app = express();
const port = process.env.PORT || config.port || 3001;

// Rate limiting configuration
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.'
});

// Security middleware
app.use(helmet({
  crossOriginEmbedderPolicy: false,
  crossOriginOpenerPolicy: false
})); 

app.use(cors({
  origin: ['http://localhost:5173', 'http://localhost:3000'],  
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  exposedHeaders: ['Content-Range', 'X-Content-Range'],
  credentials: true
}));

// Apply rate limiting to all requests
app.use(limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', authRouter);         
app.use('/api/admins', adminRouter);      
app.use('/api/users', usersRouter);
app.use('/api/orders', ordersRouter);
app.use('/api/articles', articlesRouter);
app.use('/api/notifications', notificationsRouter);
app.use('/api/categories', categoriesRouter);
app.use('/api/subscriptions', subscriptionsRouter);

// Basic route for testing
app.get('/', (req, res) => {
  res.json({ message: 'Backend API is running!' });
});

// Error handling middleware
app.use((err: AppError, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  res.status(err.statusCode || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
    code: err.errorCode || 'SERVER_ERROR'
  });
});

// Handle specific errors
process.on('uncaughtException', (error: Error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

process.on('unhandledRejection', (error: Error) => {
  console.error('Unhandled Rejection:', error);
});

// Start server with error handling
const server = app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
}).on('error', (err: NodeJS.ErrnoException) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`Port ${port} is already in use. Please try a different port.`);
    process.exit(1);
  } else {
    console.error('Server error:', err);
    process.exit(1);
  }
});
