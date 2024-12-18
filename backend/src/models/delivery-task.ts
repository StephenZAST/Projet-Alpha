import { Address } from './address';

export interface TimeSlot {
  start: string;
  end: string;
}

export interface DeliveryTask {
  estimatedDuration: number;
  deliveryLocation: any;
  pickupLocation: any;
  id: string;
  orderId: string;
  type: TaskType;
  status: TaskStatus;
  address: Address;
  scheduledTime: {
    duration: number;
    date: string;
    slot: TimeSlot;
  };
  customer: {
    id: string;
    name: string;
    phone: string;
  };
  assignedDriver?: string;
  priority: PriorityLevel;
  notes?: string;
  createdAt?: string;
  updatedAt?: string;
}

export enum TaskType {
  PICKUP = 'pickup',
  DELIVERY = 'delivery'
}

export enum TaskStatus {
  PENDING = 'pending',
  ASSIGNED = 'assigned',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed',
  FAILED = 'failed'
}

export type DeliveryTaskStatus = TaskStatus;

export enum PriorityLevel {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  URGENT = 'urgent'
}
