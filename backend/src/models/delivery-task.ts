import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export interface DeliveryTask {
  id?: string;
  deliveryId: string;
  status: 'assigned' | 'in_progress' | 'completed' | 'failed';
  assignedTo?: string;
  TaskType: 'pickup' | 'delivery';
  customer: {
    id: string;
    name: string;
    email?: string;
    phoneNumber?: string;
  };
  deliveryLocation: string;
  pickupLocation: string;
  orderId: string;
  address?: string;
  scheduledTime?: string;
  PriorityLevel: 'low' | 'medium' | 'high';
  createdAt?: string;
  updatedAt?: string;
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
export async function createDeliveryTask(deliveryTaskData: DeliveryTask): Promise<DeliveryTask> {
  const { data, error } = await supabase.from(deliveryTasksTable).insert([deliveryTaskData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create delivery task', 'INTERNAL_SERVER_ERROR');
  }

  return data as DeliveryTask;
}

// Function to update delivery task
export async function updateDeliveryTask(id: string, deliveryTaskData: Partial<DeliveryTask>): Promise<DeliveryTask> {
  const currentDeliveryTask = await getDeliveryTask(id);

  if (!currentDeliveryTask) {
    throw new AppError(404, 'Delivery task not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(deliveryTasksTable).update(deliveryTaskData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update delivery task', 'INTERNAL_SERVER_ERROR');
  }

  return data as DeliveryTask;
}

// Function to delete delivery task
export async function deleteDeliveryTask(id: string): Promise<void> {
  const deliveryTask = await getDeliveryTask(id);

  if (!deliveryTask) {
    throw new AppError(404, 'Delivery task not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(deliveryTasksTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete delivery task', 'INTERNAL_SERVER_ERROR');
  }
}
