import { getDeliveryTask, createDeliveryTask, updateDeliveryTask, deleteDeliveryTask } from './delivery-tasks/taskManagement';
import { DeliveryTask, TaskType, TaskStatus, PriorityLevel } from '../models/delivery-task';
import { AppError, errorCodes } from '../utils/errors';
import { GeoLocation } from '../utils/geo';

export class DeliveryTasksService {
  async getDeliveryTask(id: string): Promise<DeliveryTask | null> {
    return getDeliveryTask(id);
  }

  async createDeliveryTask(taskData: DeliveryTask): Promise<DeliveryTask> {
    return createDeliveryTask(taskData);
  }

  async updateDeliveryTask(id: string, taskData: Partial<DeliveryTask>): Promise<DeliveryTask> {
    return updateDeliveryTask(id, taskData);
  }

  async deleteDeliveryTask(id: string): Promise<void> {
    return deleteDeliveryTask(id);
  }

  async updateDriverLocation(driverId: string, location: GeoLocation): Promise<void> {
    console.log(`Updating driver ${driverId} location to`, location);
    // Placeholder for database update
  }

  async getTasksByArea(location: GeoLocation, radiusKm: number): Promise<DeliveryTask[]> {
    console.log(`Getting tasks near`, location, `with radius`, radiusKm);
    // Placeholder for database query
    return [];
  }
}

export const deliveryTasksService = new DeliveryTasksService();
