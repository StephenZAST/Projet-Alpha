import { User } from './user';
import { DeliveryTask } from './delivery-task';

export interface Delivery {
  id: string;
  driver: User;
  tasks: DeliveryTask[];
  status: DeliveryStatus;
  createdAt: Date;
  updatedAt: Date;
}

export enum DeliveryStatus {
  STARTED = 'started',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed',
  FAILED = 'failed',
}

export interface RouteInfo {
  distance: number; // in meters
  duration: number; // in seconds
}

export interface RouteStop {
  taskId: string;
  location: {
    latitude: number;
    longitude: number;
  };
  type: 'pickup' | 'delivery';
  estimatedArrivalTime?: Date;
}

export interface OptimizedRoute {
  driverId: string;
  route: RouteStop[];
  totalDistance: number; // in meters
  totalDuration: number; // in seconds
}
