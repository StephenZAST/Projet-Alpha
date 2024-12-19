import {
  getDeliveryTask as getDeliveryTaskUtil,
  createDeliveryTask as createDeliveryTaskUtil,
  updateDeliveryTask as updateDeliveryTaskUtil,
  deleteDeliveryTask as deleteDeliveryTaskUtil,
  assignDeliveryTask,
  updateOrderStatus
} from './delivery-tasks/taskManagement';
import { DeliveryTask, TaskType, TaskStatus, PriorityLevel } from '../models/delivery-task';
import { AppError, errorCodes } from '../utils/errors';
import { GeoLocation, calculateDistance } from '../utils/geo';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('Supabase URL or Key not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

export class DeliveryTasksService {
  async getDeliveryTask(id: string): Promise<DeliveryTask | null> {
    return getDeliveryTaskUtil(id);
  }

  async createDeliveryTask(taskData: DeliveryTask): Promise<DeliveryTask> {
    return createDeliveryTaskUtil(taskData);
  }

  async updateDeliveryTask(id: string, taskData: Partial<DeliveryTask>): Promise<DeliveryTask> {
    return updateDeliveryTaskUtil(id, taskData);
  }

  async deleteDeliveryTask(id: string): Promise<void> {
    return deleteDeliveryTaskUtil(id);
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

  async updateTaskStatus(taskId: string, status: TaskStatus, userId: string, notes?: string): Promise<boolean> {
    const { error } = await supabase
      .from('deliveryTasks')
      .update({ status, notes, driverId: userId })
      .eq('id', taskId);
  
    if (error) {
      throw new AppError(500, 'Failed to update task status', errorCodes.DATABASE_ERROR);
    }
  
    return true;
  }

  async assignDeliveryTask(taskId: string, driverId: string): Promise<void> {
    return assignDeliveryTask(taskId, driverId);
  }

  async updateOrderStatus(orderIds: string[], status: string): Promise<void> {
    return updateOrderStatus(orderIds, status);
  }
}

export const deliveryTasksService = new DeliveryTasksService();
