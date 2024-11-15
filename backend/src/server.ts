import app from './app';
import { config } from 'dotenv';

// Charger les variables d'environnement
config();

const port = process.env.PORT || 3000;

// Démarrer le serveur
app.listen(port, () => {
  console.log(`🚀 Serveur démarré sur le port ${port}`);
  console.log(`📚 Documentation API disponible sur http://localhost:${port}/api-docs`);
});
