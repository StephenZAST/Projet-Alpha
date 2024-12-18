import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import { JobScheduler } from './jobs/scheduler';
import { logger } from './utils/logger';

// Import des routes
import orderRoutes from './routes/orders';
import zoneRoutes from './routes/zones';
import billingRoutes from './routes/billing';
import authRoutes from './routes/authRoutes';
import websocketRoutes from './routes/websocket';
import adminLogRoutes from './routes/adminLogRoutes';
import googleAuthRoutes from './routes/googleAuthRoutes'; // Added import
import blogArticleRoutes from './routes/blogArticleRoutes'; // Ajout des routes de blog
import blogGeneratorRoutes from './routes/blogGeneratorRoutes';

const app = express();
const jobScheduler = new JobScheduler();

// Middleware de base
app.use(cors());
app.use(helmet());
app.use(compression());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/orders', orderRoutes);
app.use('/api/zones', zoneRoutes);
app.use('/api/billing', billingRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/websocket', websocketRoutes);
app.use('/api/adminLogs', adminLogRoutes);
app.use('/api/admin', googleAuthRoutes); // Added route
app.use('/api/blog', blogArticleRoutes); // Ajout des routes de blog
app.use('/api/blog-generator', blogGeneratorRoutes); // Ajout des routes de génération de blog

// Route de base pour vérifier que le serveur fonctionne
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

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  logger.info(`Server is running on port ${PORT}`);
  jobScheduler.startJobs();
});

// Handle graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received. Starting graceful shutdown...');
  jobScheduler.stopJobs();
  process.exit(0);
});

process.on('SIGINT', () => {
  logger.info('SIGINT received. Starting graceful shutdown...');
  jobScheduler.stopJobs();
  process.exit(0);
});

export default app;
