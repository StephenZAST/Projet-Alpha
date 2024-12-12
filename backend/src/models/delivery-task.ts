import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';
import { Address } from './address';

export interface TimeSlot {
  // Define the structure of a time slot if needed
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

export enum PriorityLevel {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  URGENT = 'urgent'
}

// Use Supabase to store delivery task data
const deliveryTasksTable = 'deliveryTasks';

// Function to get delivery task data
export async function getDeliveryTask(id: string): Promise<DeliveryTask | null> {
  const { data, error } = await supabase.from(deliveryTasksTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch delivery task', 'INTERNAL_SERVER_ERROR');
  }

  return data as DeliveryTask;
}

// Function to create delivery task
export async function createDeliveryTask(taskData: DeliveryTask): Promise<DeliveryTask> {
  const { data, error } = await supabase.from(deliveryTasksTable).insert([taskData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create delivery task', 'INTERNAL_SERVER_ERROR');
  }

  return data as DeliveryTask;
}

// Function to update delivery task
export async function updateDeliveryTask(id: string, taskData: Partial<DeliveryTask>): Promise<DeliveryTask> {
  const currentTask = await getDeliveryTask(id);

  if (!currentTask) {
    throw new AppError(404, 'Delivery task not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(deliveryTasksTable).update(taskData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update delivery task', 'INTERNAL_SERVER_ERROR');
  }

  return data as DeliveryTask;
}

// Function to delete delivery task
export async function deleteDeliveryTask(id: string): Promise<void> {
  const task = await getDeliveryTask(id);

  if (!task) {
    throw new AppError(404, 'Delivery task not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(deliveryTasksTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete delivery task', 'INTERNAL_SERVER_ERROR');
  }
}
