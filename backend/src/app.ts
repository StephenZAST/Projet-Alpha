import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import swaggerUi from 'swagger-ui-express';
import swaggerSpec from './config/swagger';
import { setupSwagger } from './swagger/definitions';
import { JobScheduler } from './jobs/scheduler';
import { logger } from './utils/logger';

// Import des routes
import orderRoutes from './routes/orders';
import zoneRoutes from './routes/zones';
import billingRoutes from './routes/billing';
import authRoutes from './routes/authRoutes';

const app = express();
const jobScheduler = new JobScheduler();

// Middleware de base
app.use(cors());
app.use(helmet());
app.use(compression());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Setup Swagger documentation
setupSwagger(app);

// Documentation Swagger
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: "API Documentation - Pressing Service",
  customfavIcon: "/assets/favicon.ico"
}));

// Routes
app.use('/api/orders', orderRoutes);
app.use('/api/zones', zoneRoutes);
app.use('/api/billing', billingRoutes);
app.use('/api/auth', authRoutes);

// Route de base pour vérifier que le serveur fonctionne
app.get('/', (req, res) => {
  res.json({ message: 'Bienvenue sur l\'API du système de gestion de blanchisserie' });
});

// Gestion des erreurs 404
app.use((req, res) => {
  res.status(404).json({ error: 'Route non trouvée' });
});

// Gestion globale des erreurs
app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Erreur interne du serveur' });
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
