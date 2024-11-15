import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';

// Import des routes
import orderRoutes from './routes/orders';
import zoneRoutes from './routes/zones';
import billingRoutes from './routes/billing';

const app = express();

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

export default app;
