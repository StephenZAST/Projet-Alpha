import { Address } from "cluster";
import { TimeSlot } from "./order";

export interface DeliveryTask {
  id: string;
  orderId: string;
  type: TaskType;
  status: TaskStatus;
  address: Address;
  scheduledTime: {
    date: Date;
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

export enum PriorityLevel {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  URGENT = 'urgent'
}
