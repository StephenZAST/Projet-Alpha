import app from './app';
import { config } from 'dotenv';
import { createServer } from 'http';
import { Server } from 'socket.io';
import { WebSocketManager } from './services/websocket.service';

// Charger les variables d'environnement
config();

const port = process.env.PORT || 3001; // Change default port to 3001

// Créer un serveur HTTP à partir de l'application Express
const httpServer = createServer(app);

// Initialiser Socket.IO
const io = new Server(httpServer, {
  cors: {
    origin: '*', // À personnaliser selon vos besoins de sécurité
    methods: ['GET', 'POST']
  }
});

// Initialiser le gestionnaire WebSocket
const websocketManager = new WebSocketManager(io);

// Démarrer le serveur
httpServer.listen(port, () => {
  console.log(`🚀 Serveur démarré sur le port ${port}`);
  console.log(`📚 Documentation API disponible sur http://localhost:${port}/api-docs`);
});

export { io, websocketManager };
