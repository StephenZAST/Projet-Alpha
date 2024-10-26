import { db } from './firebase';
import { DeliveryTask, TaskStatus, TaskType } from '../models/delivery-task';
import { GeoPoint } from '../models/address';

export class DeliveryTaskService {
  private readonly tasksRef = db.collection('delivery_tasks');
  private readonly ordersRef = db.collection('orders');

  async getAvailableTasks(driverId: string): Promise<DeliveryTask[]> {
    const snapshot = await this.tasksRef
      .where('status', 'in', ['pending', 'assigned'])
      .where('assignedDriver', '==', driverId)
      .orderBy('scheduledTime.date')
      .orderBy('priority', 'desc')
      .get();

    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as DeliveryTask));
  }

  async getTasksByArea(center: GeoPoint, radiusKm: number): Promise<DeliveryTask[]> {
    // Implementation using geohashing or Firebase GeoQueries
    // This would show tasks within a specific radius of the driver
    return [];
  }

  async updateTaskStatus(
    taskId: string,
    status: TaskStatus,
    driverId: string,
    notes?: string
  ): Promise<boolean> {
    try {
      await this.tasksRef.doc(taskId).update({
        status,
        lastUpdated: new Date(),
        lastUpdatedBy: driverId,
        notes: notes ? notes : null
      });

      // If task is completed, update order status
      if (status === TaskStatus.COMPLETED) {
        const task = (await this.tasksRef.doc(taskId).get()).data() as DeliveryTask;
        await this.updateOrderStatus(task.orderId, task.type);
      }

      return true;
    } catch (error) {
      console.error('Error updating task status:', error);
      return false;
    }
  }

  private async updateOrderStatus(orderId: string, taskType: TaskType) {
    const newStatus = taskType === TaskType.PICKUP ? 'PICKED_UP' : 'DELIVERED';
    await this.ordersRef.doc(orderId).update({
      status: newStatus,
      lastUpdated: new Date()
    });
  }
}
