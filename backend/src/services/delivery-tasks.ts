import { getDeliveryTask, createDeliveryTask, updateDeliveryTask, deleteDeliveryTask } from './delivery-tasks/taskManagement';
import { DeliveryTask, TaskType, TaskStatus, PriorityLevel } from '../models/delivery-task';
import { AppError, errorCodes } from '../utils/errors';

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
}

export const deliveryTasksService = new DeliveryTasksService();
