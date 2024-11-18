import WebSocket from 'ws';
import http from 'http';
import { isAuthenticated } from '../middleware/auth';
import { Cache } from '../utils/cache';
import { GeoLocation } from '../utils/geo';
import { DeliveryTaskService } from './delivery-tasks';

interface WebSocketMessage {
  type: 'location' | 'geofence' | 'task' | 'error';
  payload: any;
}

interface DriverConnection {
  ws: WebSocket;
  driverId: string;
  lastLocation?: GeoLocation;
}

export class WebSocketService {
  private wss: WebSocket.Server;
  private connections: Map<string, DriverConnection>;
  private locationCache: Cache<string, GeoLocation>;
  private deliveryTaskService: DeliveryTaskService;
  private geofenceCache: Cache<string, any>;

  constructor(server: http.Server) {
    this.wss = new WebSocket.Server({ server });
    this.connections = new Map();
    this.locationCache = new Cache<string, GeoLocation>(300); // 5 minutes TTL
    this.geofenceCache = new Cache<string, any>(3600); // 1 hour TTL
    this.deliveryTaskService = new DeliveryTaskService();

    this.setupWebSocket();
    this.startLocationBatchProcessor();
  }

  private setupWebSocket() {
    this.wss.on('connection', async (ws: WebSocket, req: http.IncomingMessage) => {
      try {
        // Extract and verify token from query string
        const token = new URL(req.url!, `http://${req.headers.host}`).searchParams.get('token');
        if (!token) {
          ws.close(1008, 'Missing authentication token');
          return;
        }

        // @ts-ignore
        const decoded: any = await isAuthenticated({ headers: { authorization: `Bearer ${token}` } } as any, {} as any, () => {});
        const driverId = decoded.user?.id;

        if (!driverId) {
          ws.close(1008, 'Authentication failed');
          return;
        }

        // Store connection
        this.connections.set(driverId, { ws, driverId });

        // Setup message handler
        ws.on('message', (data: string) => this.handleMessage(driverId, data));

        // Setup close handler
        ws.on('close', () => {
          this.connections.delete(driverId);
          console.log(`Driver ${driverId} disconnected`);
        });

        console.log(`Driver ${driverId} connected`);
      } catch (error) {
        console.error('WebSocket connection error:', error);
        ws.close(1008, 'Authentication failed');
      }
    });
  }

  private async handleMessage(driverId: string, data: string) {
    try {
      const message: WebSocketMessage = JSON.parse(data);
      const connection = this.connections.get(driverId);

      if (!connection) {
        console.error(`No connection found for driver ${driverId}`);
        return;
      }

      switch (message.type) {
        case 'location':
          await this.handleLocationUpdate(driverId, message.payload);
          break;
        case 'geofence':
          await this.handleGeofenceEvent(driverId, message.payload);
          break;
        default:
          console.warn(`Unknown message type: ${message.type}`);
      }
    } catch (error) {
      console.error('Error handling WebSocket message:', error);
      this.sendError(driverId, 'Error processing message');
    }
  }

  private async handleLocationUpdate(driverId: string, location: string) {
    try {
      const parsedLocation: GeoLocation = JSON.parse(location);

      // Cache the location
      this.locationCache.set(driverId, parsedLocation);

      // Update driver's location in database (batch processed)
      await this.deliveryTaskService.updateDriverLocation(driverId, parsedLocation);

      // Check for nearby tasks
      const tasks = await this.deliveryTaskService.getTasksByArea(parsedLocation, 5);
      if (tasks.length > 0) {
        this.sendMessage(driverId, {
          type: 'task',
          payload: { nearbyTasks: tasks }
        });
      }

      // Check geofences
      await this.checkGeofences(driverId, parsedLocation);
    } catch (error) {
      console.error('Error handling location update:', error);
    }
  }

  private async handleGeofenceEvent(driverId: string, event: any) {
    try {
      // Process geofence entry/exit events
      const { zoneId, eventType } = event;

      // Notify relevant parties about zone entry/exit
      this.broadcastToZone(zoneId, {
        type: 'geofence',
        payload: {
          driverId,
          zoneId,
          eventType,
          timestamp: new Date()
        }
      });
    } catch (error) {
      console.error('Error handling geofence event:', error);
    }
  }

  private async checkGeofences(driverId: string, location: GeoLocation) {
    const zones = this.geofenceCache.get('zones') || [];
    for (const zone of zones) {
      const wasInZone = this.geofenceCache.get(`${driverId}:${zone.id}`);
      const isInZone = this.isPointInZone(location, zone);

      if (isInZone !== wasInZone) {
        this.geofenceCache.set(`${driverId}:${zone.id}`, isInZone);
        await this.handleGeofenceEvent(driverId, {
          zoneId: zone.id,
          eventType: isInZone ? 'enter' : 'exit'
        });
      }
    }
  }

  private isPointInZone(location: GeoLocation, zone: any): boolean {
    // Implement zone boundary check using isPointInPolygon from geo utils
    return false; // Placeholder
  }

  private startLocationBatchProcessor() {
    // Process location updates in batches every 5 seconds
    setInterval(() => {
      const locations = new Map<string, GeoLocation>();

      // Collect all cached locations
      for (const [driverId, location] of this.locationCache.getStats().keys) {
        locations.set(driverId, location as unknown as GeoLocation);
      }

      // Batch update if there are any locations
      if (locations.size > 0) {
        this.batchUpdateLocations(locations).catch(error => {
          console.error('Error in batch location update:', error);
        });
      }
    }, 5000);
  }

  private async batchUpdateLocations(locations: Map<string, GeoLocation>) {
    // Implement batch update to database
    // This would be implemented in the database service
  }

  private sendMessage(driverId: string, message: WebSocketMessage) {
    const connection = this.connections.get(driverId);
    if (connection && connection.ws.readyState === WebSocket.OPEN) {
      connection.ws.send(JSON.stringify(message));
    }
  }

  private sendError(driverId: string, error: string) {
    this.sendMessage(driverId, {
      type: 'error',
      payload: { message: error }
    });
  }

  private broadcastToZone(zoneId: string, message: WebSocketMessage) {
    this.connections.forEach(connection => {
      // In a real implementation, we'd check if the connection is relevant to this zone
      this.sendMessage(connection.driverId, message);
    });
  }
}
