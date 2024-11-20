import { Server, Socket } from 'socket.io';
import { logger } from '../utils/logger';

export class WebSocketManager {
  private io: Server;
  private connectedClients: Map<string, Socket> = new Map();

  constructor(io: Server) {
    this.io = io;
    this.setupEventListeners();
  }

  private setupEventListeners(): void {
    this.io.on('connection', (socket: Socket) => {
      logger.info(`New WebSocket connection: ${socket.id}`);
      this.connectedClients.set(socket.id, socket);

      // Example custom event handlers
      this.setupDeliveryEvents(socket);
      this.setupOrderEvents(socket);

      socket.on('disconnect', () => {
        logger.info(`WebSocket disconnected: ${socket.id}`);
        this.connectedClients.delete(socket.id);
      });
    });
  }

  private setupDeliveryEvents(socket: Socket): void {
    socket.on('delivery:track', (data) => {
      logger.info(`Tracking delivery: ${JSON.stringify(data)}`);
      // Implement delivery tracking logic
      this.broadcastToRoom(`delivery:${data.deliveryId}`, 'delivery:status', data);
    });
  }

  private setupOrderEvents(socket: Socket): void {
    socket.on('order:status', (data) => {
      logger.info(`Order status update: ${JSON.stringify(data)}`);
      // Implement order status update logic
      this.broadcastToRoom(`order:${data.orderId}`, 'order:update', data);
    });
  }

  // Broadcast to all connected clients
  public broadcast(event: string, data: any): void {
    this.io.emit(event, data);
  }

  // Send to a specific client
  public sendToClient(clientId: string, event: string, data: any): void {
    const socket = this.connectedClients.get(clientId);
    if (socket) {
      socket.emit(event, data);
    }
  }

  // Join a room
  public joinRoom(socket: Socket, roomName: string): void {
    socket.join(roomName);
    logger.info(`Socket ${socket.id} joined room: ${roomName}`);
  }

  // Leave a room
  public leaveRoom(socket: Socket, roomName: string): void {
    socket.leave(roomName);
    logger.info(`Socket ${socket.id} left room: ${roomName}`);
  }

  // Broadcast to a specific room
  public broadcastToRoom(roomName: string, event: string, data: any): void {
    this.io.to(roomName).emit(event, data);
  }

  // Get number of connected clients
  public getConnectedClientsCount(): number {
    return this.connectedClients.size;
  }
}
