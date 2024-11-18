import { db } from '../config/firebase';
import { DeliveryTask, TaskStatus, TaskType } from '../models/delivery-task';
import { GeoPoint } from 'firebase-admin/firestore';
import { 
  GeoLocation, 
  calculateDistance, 
  generateGeohash, 
  getGeohashRange,
  isPointInPolygon 
} from '../utils/geo';
import { Cache } from '../utils/cache';

interface TaskWithDistance extends DeliveryTask {
  distance?: number;
}

export class DeliveryTaskService {
  private readonly tasksRef = db.collection('delivery_tasks');
  private readonly ordersRef = db.collection('orders');
  private readonly driversRef = db.collection('drivers');
  private readonly zonesRef = db.collection('zones');
  private readonly locationCache: Cache<string, GeoLocation>;

  constructor() {
    // Initialize cache with 5 minutes TTL
    this.locationCache = new Cache<string, GeoLocation>(300000);
  }

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

  async getTasksByArea(center: GeoLocation, radiusKm: number): Promise<TaskWithDistance[]> {
    try {
      // Get geohash range for the search area
      const { lower, upper } = getGeohashRange(center, radiusKm);

      // Query tasks within geohash range
      const snapshot = await this.tasksRef
        .where('status', 'in', ['pending', 'assigned'])
        .where('geohash', '>=', lower)
        .where('geohash', '<=', upper)
        .get();

      // Calculate actual distances and filter
      const tasksWithDistance = await Promise.all(
        snapshot.docs.map(async doc => {
          const task = doc.data() as DeliveryTask;
          const location = task.pickupLocation || task.deliveryLocation;

          if (!location) return null;

          const distance = calculateDistance(center, location);
          if (distance <= radiusKm) {
            return {
              id: doc.id,
              ...task,
              distance
            };
          }
          return null;
        })
      );

      // Remove nulls and sort by distance
      return tasksWithDistance
        .filter((task): task is TaskWithDistance => task !== null)
        .sort((a, b) => (a.distance || 0) - (b.distance || 0));
    } catch (error) {
      console.error('Error getting tasks by area:', error);
      throw error;
    }
  }

  async updateDriverLocation(
    driverId: string,
    location: GeoLocation,
    forceUpdate: boolean = false
  ): Promise<void> {
    try {
      const cachedLocation = this.locationCache.get(driverId);
      
      // Skip update if location hasn't changed significantly and force update not requested
      if (!forceUpdate && cachedLocation && 
          calculateDistance(cachedLocation, location) < 0.1) { // Less than 100m change
        return;
      }

      // Generate geohash for the location
      const geohash = generateGeohash(location);

      // Update driver's location in Firestore
      await this.driversRef.doc(driverId).update({
        currentLocation: new GeoPoint(location.latitude, location.longitude),
        geohash,
        lastLocationUpdate: new Date(),
        isOnline: true
      });

      // Update cache
      this.locationCache.set(driverId, location);

      // Check for nearby tasks that might need reassignment
      await this.checkNearbyTasks(driverId, location);
    } catch (error) {
      console.error('Error updating driver location:', error);
      throw error;
    }
  }

  private async checkNearbyTasks(driverId: string, location: GeoLocation): Promise<void> {
    try {
      const nearbyTasks = await this.getTasksByArea(location, 5); // 5km radius
      const unassignedTasks = nearbyTasks.filter(task => !task.assignedDriver);

      if (unassignedTasks.length > 0) {
        // Get driver's current workload
        const currentTasks = await this.getAvailableTasks(driverId);
        
        // Only assign new tasks if driver's workload is below threshold
        if (currentTasks.length < 5) { // Maximum 5 active tasks per driver
          await this.assignNearbyTasks(driverId, unassignedTasks);
        }
      }
    } catch (error) {
      console.error('Error checking nearby tasks:', error);
      // Don't throw error to prevent blocking location update
    }
  }

  private async assignNearbyTasks(
    driverId: string,
    tasks: TaskWithDistance[]
  ): Promise<void> {
    try {
      // Sort tasks by priority and distance
      const sortedTasks = tasks.sort((a, b) => {
        const priorityA = this.getPriorityScore(a);
        const priorityB = this.getPriorityScore(b);
        return priorityB - priorityA;
      });

      // Assign the highest priority task
      if (sortedTasks.length > 0) {
        const taskToAssign = sortedTasks[0];
        await this.tasksRef.doc(taskToAssign.id).update({
          assignedDriver: driverId,
          status: TaskStatus.ASSIGNED,
          lastUpdated: new Date()
        });
      }
    } catch (error) {
      console.error('Error assigning nearby tasks:', error);
      throw error;
    }
  }

  private getPriorityScore(task: TaskWithDistance): number {
    // Calculate priority score based on multiple factors
    let score = 0;
    
    // Distance factor (closer = higher score)
    score += task.distance ? (10 - Math.min(task.distance, 10)) : 0;
    
    // Time factor (older = higher score)
    const waitingTime = Date.now() - task.createdAt.getTime();
    score += Math.min(waitingTime / (1000 * 60 * 60), 24); // Max 24 hours
    
    // Priority level factor
    switch (task.priority) {
      case 'urgent':
        score += 50;
        break;
      case 'high':
        score += 30;
        break;
      case 'medium':
        score += 20;
        break;
      case 'low':
        score += 10;
        break;
    }
    
    return score;
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
        notes: notes || null
      });

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

  private async updateOrderStatus(orderId: string, taskType: TaskType): Promise<void> {
    const newStatus = taskType === TaskType.PICKUP ? 'PICKED_UP' : 'DELIVERED';
    await this.ordersRef.doc(orderId).update({
      status: newStatus,
      lastUpdated: new Date()
    });
  }
}
