import express from 'express';
import cors from 'cors';
import { config } from './config';
import { createServer } from 'http';
import { Server } from 'socket.io';
import { WebSocketManager } from './services/websocket.service';
import adminRoutes from './routes/admins';
import authRoutes from './routes/auth';
import userRoutes from './routes/users';
import orderRoutes from './routes/orders';

const app = express();

// Middleware de base
app.use(cors({
  origin: config.allowedOrigins,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  credentials: true
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/admins', adminRoutes);
app.use('/api/users', userRoutes);
app.use('/api/orders', orderRoutes);

// Créer un serveur HTTP
const httpServer = createServer(app);

// Initialiser Socket.IO avec CORS
const io = new Server(httpServer, {
  cors: {
    origin: config.allowedOrigins,
    methods: ['GET', 'POST'],
    credentials: true
  }
});

// Initialiser WebSocket
const websocketManager = new WebSocketManager(io);

// Route de test
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running' });
});

// Démarrer le serveur
const PORT = config.port || 5000;
httpServer.listen(PORT, () => {
  console.log(`🚀 Server is running on port ${PORT}`);
  console.log(`📚 API Documentation: http://localhost:${PORT}/api-docs`);
});

export { app, io, websocketManager };
