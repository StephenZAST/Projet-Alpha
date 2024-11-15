import { Timestamp } from 'firebase-admin/firestore';
import { Location } from './order';

export interface RouteInfo {
  orderId: string;
  location: Location;
  type: 'pickup' | 'delivery';
  scheduledTime: Timestamp;
  status: 'pending' | 'completed';
  address: string;
  contactName?: string;
  contactPhone?: string;
}

export interface OptimizedRoute {
  deliveryPersonId: string;
  zoneId: string;
  date: Timestamp;
  stops: RouteInfo[];
  estimatedDuration: number; // en minutes
  estimatedDistance: number; // en kilomètres
  startLocation: Location;
  endLocation: Location;
}

export interface DeliveryTask {
  id?: string;
  deliveryPersonId: string;
  orderId: string;
  type: 'pickup' | 'delivery';
  status: 'pending' | 'in_progress' | 'completed' | 'failed';
  scheduledTime: Timestamp;
  completedTime?: Timestamp;
  location: Location;
  address: string;
  notes?: string;
  proof?: {
    signature?: string;
    photo?: string;
    notes?: string;
  };
}
