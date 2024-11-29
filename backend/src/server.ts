import app from './app';
import { config } from './config';
import { createServer } from 'http';
import { Server } from 'socket.io';
import { WebSocketManager } from './services/websocket.service';

// Charger les variables d'environnement
// config();

// Créer un serveur HTTP à partir de l'application Express
const httpServer = createServer(app);

// Initialiser Socket.IO
const io = new Server(httpServer, {
  cors: {
    origin: config.allowedOrigins,
    methods: ['GET', 'POST'],
    credentials: true
  }
});

// Initialiser le gestionnaire WebSocket
const websocketManager = new WebSocketManager(io);

// Démarrer le serveur
httpServer.listen(config.port, () => {
  console.log(`🚀 Serveur démarré sur le port ${config.port}`);
  console.log(`📚 Documentation API disponible sur http://localhost:${config.port}/api-docs`);
});

export { io, websocketManager };
