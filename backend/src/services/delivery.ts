import { createClient } from '@supabase/supabase-js';
import { RouteInfo, OptimizedRoute } from '../models/delivery';
import { AppError, errorCodes } from '../utils/errors';
import { UserRole } from '../models/user';
import { Order, OrderStatus } from '../models/order';
import { DeliveryTask, DeliveryTaskStatus } from '../models/delivery-task';
import { GeoLocation, calculateDistance } from '../utils/geo';
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

export class DeliveryService {
  async getAvailableTimeSlots(date: Date, zoneId: string): Promise<any[]> {
    // Placeholder for fetching available time slots from Supabase
    // This will involve querying a 'timeSlots' table or similar
    // and filtering by date and zoneId.
    console.log(`Fetching available time slots for date: ${date} and zoneId: ${zoneId}`);
    return [];
  }

  async schedulePickup(orderId: string, date: Date, timeSlot: string, address: any): Promise<void> {
    // Placeholder for scheduling a pickup
    // This will involve updating the order with the pickup details
    // and possibly creating a new delivery task.
    console.log(`Scheduling pickup for orderId: ${orderId}, date: ${date}, timeSlot: ${timeSlot}, address: ${address}`);
  }

  async updateOrderLocation(orderId: string, location: any, status: string): Promise<void> {
    // Placeholder for updating order location and status
    // This will involve updating the order in the 'orders' table.
    console.log(`Updating location for orderId: ${orderId}, location: ${location}, status: ${status}`);
  }

  async getTasks(query: any): Promise<DeliveryTask[]> {
    // Placeholder for fetching tasks based on query parameters
    // This will involve querying the 'deliveryTasks' table with filters.
    console.log(`Fetching tasks with query: ${query}`);
    return [];
  }

  async getTaskById(taskId: string): Promise<DeliveryTask | null> {
    return getDeliveryTask(taskId);
  }

  async createTask(taskData: DeliveryTask): Promise<DeliveryTask> {
    return createDeliveryTask(taskData);
  }

  async updateTask(taskId: string, taskData: Partial<DeliveryTask>): Promise<DeliveryTask> {
    return updateDeliveryTask(taskId, taskData);
  }

  async optimizeRoute(taskIds: string[], driverId: string, startLocation: any, endLocation: any, maxTasks: number, considerTraffic: boolean): Promise<OptimizedRoute> {
    // Placeholder for route optimization logic
    // This will likely involve using a routing API or algorithm
    console.log(`Optimizing route for taskIds: ${taskIds}, driverId: ${driverId}, startLocation: ${startLocation}, endLocation: ${endLocation}, maxTasks: ${maxTasks}, considerTraffic: ${considerTraffic}`);
    return {
      driverId,
      route: [],
      totalDistance: 0,
      totalDuration: 0,
    };
  }

  async updateLocation(locationData: any): Promise<void> {
    // Placeholder for updating a location
    // This might involve updating a 'locations' table or similar
    console.log(`Updating location with data: ${locationData}`);
  }

  async getZones(): Promise<any[]> {
    // Placeholder for fetching delivery zones
    // This will involve querying a 'zones' table or similar
    console.log(`Fetching delivery zones`);
    return [];
  }

  async updateDriverLocation(driverId: string, location: GeoLocation): Promise<void> {
    const { error } = await supabase.from('drivers').update({ location }).eq('id', driverId);

    if (error) {
      throw new AppError(500, 'Failed to update driver location', errorCodes.DATABASE_ERROR);
    }
  }

  async getTasksByArea(location: GeoLocation, radiusKm: number): Promise<DeliveryTask[]> {
    const { data, error } = await supabase.from('deliveryTasks').select('*');

    if (error) {
      throw new AppError(500, 'Failed to fetch tasks', errorCodes.DATABASE_ERROR);
    }

    const tasksWithinRadius = (data as DeliveryTask[]).filter(task => {
      const taskLocation: GeoLocation = {
        latitude: task.pickupLocation?.latitude || 0,
        longitude: task.pickupLocation?.longitude || 0
      };
      const distance = calculateDistance(location, taskLocation);
      return distance <= radiusKm;
    });

    return tasksWithinRadius;
  }

  async getAvailableTasks(userId: string): Promise<DeliveryTask[]> {
    const { data, error } = await supabase
      .from('deliveryTasks')
      .select('*')
      .eq('status', 'available');

    if (error) {
      throw new AppError(500, 'Failed to fetch available tasks', errorCodes.DATABASE_ERROR);
    }

    return data as DeliveryTask[];
  }

  async updateTaskStatus(taskId: string, status: DeliveryTaskStatus, userId: string, notes?: string): Promise<boolean> {
    const { error } = await supabase
      .from('deliveryTasks')
      .update({ status, notes, driverId: userId })
      .eq('id', taskId);

    if (error) {
      throw new AppError(500, 'Failed to update task status', errorCodes.DATABASE_ERROR);
    }

    return true;
  }
}

export const deliveryService = new DeliveryService();
