import { Timestamp } from 'firebase-admin/firestore';
import { Location } from './order';

export interface Zone {
  id?: string;
  name: string;
  description?: string;
  boundaries: Location[];
  deliveryFee: number;
  minimumOrderAmount: number;
  estimatedDeliveryTime: number; // en minutes
  isActive: boolean;
  maxOrders: number;
  currentOrders: number;
  specialInstructions?: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface ZoneAssignment {
  id?: string;
  zoneId: string;
  deliveryPersonId: string;
  startTime: Timestamp;
  endTime: Timestamp;
  isActive: boolean;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

export interface ZoneCapacity {
  id?: string;
  zoneId: string;
  date: Timestamp;
  maxOrders: number;
  currentOrders: number;
  timeSlots: TimeSlot[];
}

export interface TimeSlot {
  startTime: string; // Format: "HH:mm"
  endTime: string; // Format: "HH:mm"
  maxOrders: number;
  currentOrders: number;
  isAvailable: boolean;
}

export interface ZoneStats {
  zoneId: string;
  period: string;
  totalOrders: number;
  completedOrders: number;
  cancelledOrders: number;
  averageDeliveryTime: number;
  totalRevenue: number;
  deliveryFees: number;
}
