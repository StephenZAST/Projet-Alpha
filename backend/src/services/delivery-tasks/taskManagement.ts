import { createClient } from '@supabase/supabase-js';
import { DeliveryTask, TaskType, TaskStatus, PriorityLevel } from '../../models/delivery-task';
import { AppError, errorCodes } from '../../utils/errors';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

const deliveryTasksTable = 'deliveryTasks';

export async function getDeliveryTask(id: string): Promise<DeliveryTask | null> {
  try {
    const { data, error } = await supabase.from(deliveryTasksTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch delivery task', errorCodes.DATABASE_ERROR);
    }

    return data as DeliveryTask;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch delivery task', errorCodes.DATABASE_ERROR);
  }
}

export async function createDeliveryTask(taskData: DeliveryTask): Promise<DeliveryTask> {
  try {
    const { data, error } = await supabase.from(deliveryTasksTable).insert([taskData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create delivery task', errorCodes.DATABASE_ERROR);
    }

    return data as DeliveryTask;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create delivery task', errorCodes.DATABASE_ERROR);
  }
}

export async function updateDeliveryTask(id: string, taskData: Partial<DeliveryTask>): Promise<DeliveryTask> {
  try {
    const currentTask = await getDeliveryTask(id);

    if (!currentTask) {
      throw new AppError(404, 'Delivery task not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(deliveryTasksTable).update(taskData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update delivery task', errorCodes.DATABASE_ERROR);
    }

    return data as DeliveryTask;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update delivery task', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteDeliveryTask(id: string): Promise<void> {
  try {
    const task = await getDeliveryTask(id);

    if (!task) {
      throw new AppError(404, 'Delivery task not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(deliveryTasksTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete delivery task', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete delivery task', errorCodes.DATABASE_ERROR);
  }
}

export async function assignDeliveryTask(taskId: string, driverId: string): Promise<void> {
  try {
    const { error } = await supabase
      .from(deliveryTasksTable)
      .update({ driverId, status: 'assigned' })
      .eq('id', taskId);

    if (error) {
      throw new AppError(500, 'Failed to assign delivery task', errorCodes.DATABASE_ERROR);
    }
  } catch (error) {
    console.error('Error assigning delivery task:', error);
    throw error;
  }
}

export async function updateOrderStatus(orderIds: string[], status: string): Promise<void> {
  try {
    const { error } = await supabase
      .from('orders')
      .update({ status })
      .in('id', orderIds);

    if (error) {
      throw new AppError(500, 'Failed to update order status', errorCodes.DATABASE_ERROR);
    }
  } catch (error) {
    console.error('Error updating order status:', error);
    throw error;
  }
}
