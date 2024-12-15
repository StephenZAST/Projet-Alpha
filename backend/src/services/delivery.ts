import { createClient } from '@supabase/supabase-js';
import { DeliveryTask, RouteInfo, OptimizedRoute } from '../models/delivery';
import { AppError, errorCodes } from '../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

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

export async function checkDeliverySlotAvailability(zoneId: string, date: Date): Promise<boolean> {
  try {
    const { data, error } = await supabase.from('deliverySlots').select('id').eq('zoneId', zoneId).eq('date', date.toISOString());

    if (error) {
      throw new AppError(500, 'Failed to check delivery slot availability', errorCodes.DATABASE_ERROR);
    }

    return data.length > 0;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to check delivery slot availability', errorCodes.DATABASE_ERROR);
  }
}
