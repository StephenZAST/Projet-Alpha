import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export interface RouteInfo {
  orderId: string;
  location: any; // Changed to any for now
  type: 'pickup' | 'delivery';
  scheduledTime: string;
  status: 'pending' | 'completed';
  address: string;
  contactName?: string;
  contactPhone?: string;
}

export interface OptimizedRoute {
  deliveryPersonId: string;
  zoneId: string;
  date: string;
  stops: RouteInfo[];
  estimatedDuration: number; // en minutes
  estimatedDistance: number; // en kilomètres
  startLocation: any; // Changed to any for now
  endLocation: any; // Changed to any for now
}

export interface DeliveryTask {
  id?: string;
  deliveryPersonId: string;
  orderId: string;
  type: 'pickup' | 'delivery';
  status: 'pending' | 'in_progress' | 'completed' | 'failed';
  scheduledTime: string;
  completedTime?: string;
  location: any; // Changed to any for now
  address: string;
  notes?: string;
  proof?: {
    signature?: string;
    photo?: string;
    notes?: string;
  };
  createdAt?: string;
  updatedAt?: string;
}

// Use Supabase to store delivery data
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
