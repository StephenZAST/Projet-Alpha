import { db } from './firebase';
import { Zone, ZoneStatus } from '../models/zone';
import { AppError, errorCodes } from '../utils/errors';
import { GeoPoint, FieldValue, Timestamp } from 'firebase-admin/firestore';
import { Query, CollectionReference } from 'firebase-admin/firestore'; // Import Query and CollectionReference

export class ZoneService {
  async createZone(zone: Zone): Promise<Zone> {
    try {
      const zoneRef = await db.collection('zones').add({
        ...zone,
        createdAt: Timestamp.now(),
        status: ZoneStatus.ACTIVE,
        updatedAt: Timestamp.now()
      });
      
      return { ...zone, id: zoneRef.id };
    } catch (error) {
      console.error('Error creating zone:', error);
      throw new AppError(500, 'Failed to create zone', errorCodes.ZONE_CREATION_FAILED);
    }
  }

  async getZoneById(zoneId: string): Promise<Zone | null> {
    try {
      const zoneDoc = await db.collection('zones').doc(zoneId).get();
      
      if (!zoneDoc.exists) {
        return null;
      }
      
      return { id: zoneDoc.id, ...zoneDoc.data() } as Zone;
    } catch (error) {
      console.error('Error fetching zone:', error);
      throw new AppError(500, 'Failed to fetch zone', errorCodes.ZONES_FETCH_FAILED); // Fixed typo
    }
  }

  async getAllZones(options: {
    name?: string;
    isActive?: boolean;
    deliveryPersonId?: string;
    location?: any;
    page?: number;
    limit?: number;
  } = {}): Promise<Zone[]> {
    try {
      let query: Query | CollectionReference = db.collection('zones'); // Start with CollectionReference

      if (options.name) {
        query = query.where('name', '==', options.name); // Apply where on CollectionReference
      }

      if (options.isActive !== undefined) {
        query = query.where('isActive', '==', options.isActive); // Apply where on CollectionReference
      }

      if (options.deliveryPersonId) {
        query = query.where('deliveryPersonId', '==', options.deliveryPersonId); // Apply where on CollectionReference
      }

      // Add geoquery based on location if provided

      // Apply pagination
      if (options.page && options.limit) {
        const offset = (options.page - 1) * options.limit;
        query = query.offset(offset).limit(options.limit); // Apply offset and limit on Query
      }

      const zonesSnapshot = await query.get();
      return zonesSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      } as Zone));
    } catch (error) {
      console.error('Error fetching zones:', error);
      throw new AppError(500, 'Failed to fetch zones', errorCodes.ZONES_FETCH_FAILED);
    }
  }

  async updateZone(zoneId: string, updates: Partial<Zone>): Promise<boolean> {
    try {
      await db.collection('zones').doc(zoneId).update({
        ...updates,
        updatedAt: Timestamp.now()
      });
      return true;
    } catch (error) {
      console.error('Error updating zone:', error);
      throw new AppError(500, 'Failed to update zone', errorCodes.ZONE_UPDATE_FAILED);
    }
  }

  async deleteZone(zoneId: string): Promise<boolean> {
    try {
      // Vérifier si la zone existe
      const zoneDoc = await db.collection('zones').doc(zoneId).get();
      if (!zoneDoc.exists) {
        throw new AppError(404, 'Zone not found', errorCodes.ZONE_NOT_FOUND);
      }

      // Vérifier s'il y a des commandes actives dans la zone
      const activeOrders = await db.collection('orders')
        .where('zoneId', '==', zoneId)
        .where('status', 'in', ['pending', 'processing', 'assigned'])
        .get();

      if (!activeOrders.empty) {
        throw new AppError(400, 'Cannot delete zone with active orders', errorCodes.ZONE_HAS_ACTIVE_ORDERS);
      }

      // Supprimer la zone
      await db.collection('zones').doc(zoneId).delete();
      return true;
    } catch (error) {
      console.error('Error deleting zone:', error);
      throw new AppError(500, 'Failed to delete zone', errorCodes.ZONE_DELETION_FAILED);
    }
  }

  async assignDeliveryPerson(
    zoneId: string,
    deliveryPersonId: string
  ): Promise<boolean> {
    try {
      const zoneRef = db.collection('zones').doc(zoneId);
      const deliveryPersonRef = db.collection('deliveryPersons').doc(deliveryPersonId);

      const [zoneDoc, deliveryPersonDoc] = await Promise.all([
        zoneRef.get(),
        deliveryPersonRef.get()
      ]);

      if (!zoneDoc.exists) {
        throw new AppError(404, 'Zone not found', errorCodes.ZONE_NOT_FOUND);
      }

      if (!deliveryPersonDoc.exists) {
        throw new AppError(404, 'Delivery person not found', errorCodes.DELIVERY_PERSON_NOT_FOUND);
      }

      if (deliveryPersonDoc.data()?.status !== 'available') {
        throw new AppError(400, 'Delivery person is not available', errorCodes.DELIVERY_PERSON_UNAVAILABLE);
      }

      await Promise.all([
        zoneRef.update({
          deliveryPersonId,
          updatedAt: Timestamp.now()
        }),
        deliveryPersonRef.update({
          zoneId,
          status: 'assigned',
          updatedAt: Timestamp.now()
        })
      ]);

      return true;
    } catch (error) {
      console.error('Error assigning delivery person to zone:', error);
      throw new AppError(500, 'Failed to assign delivery person', errorCodes.ZONE_ASSIGNMENT_FAILED);
    }
  }

  async getZoneStatistics(
    zoneId: string,
    startDate?: Date,
    endDate?: Date
  ) {
    try {
      const zoneDoc = await db.collection('zones').doc(zoneId).get();
      if (!zoneDoc.exists) {
        throw new AppError(404, 'Zone not found', errorCodes.ZONE_NOT_FOUND);
      }

      let query = db.collection('orders').where('zoneId', '==', zoneId);
      
      if (startDate) {
        query = query.where('createdAt', '>=', startDate);
      }
      if (endDate) {
        query = query.where('createdAt', '<=', endDate);
      }

      const ordersSnapshot = await query.get();
      const orders = ordersSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

      const averageDeliveryTime = this.calculateAverageDeliveryTime(orders);
      const totalRevenue = this.calculateTotalRevenue(orders);
      const busyHours = this.calculateBusyHours(orders);
      const deliveryPersonsStats = await this.getDeliveryPersonsStats(zoneId);

      return {
        totalOrders: orders.length,
        averageDeliveryTime,
        totalRevenue,
        busyHours,
        deliveryPersonsStats,
        period: {
          start: startDate || null,
          end: endDate || null
        }
      };
    } catch (error) {
      console.error('Error fetching zone statistics:', error);
      throw new AppError(500, 'Failed to fetch zone statistics', errorCodes.ZONE_STATS_FETCH_FAILED);
    }
  }

  private calculateAverageDeliveryTime(orders: any[]): number {
    if (orders.length === 0) return 0;

    const totalTime = orders.reduce((sum, order) => {
      if (order.deliveredAt && order.pickedUpAt) {
        return sum + (order.deliveredAt.toMillis() - order.pickedUpAt.toMillis());
      }
      return sum;
    }, 0);

    return totalTime / orders.length / (1000 * 60); // Convert to minutes
  }

  private calculateTotalRevenue(orders: any[]): number {
    return orders.reduce((sum, order) => sum + (order.totalAmount || 0), 0);
  }

  private calculateBusyHours(orders: any[]): { hour: number; count: number }[] {
    const hourCounts = new Array(24).fill(0);

    orders.forEach(order => {
      if (order.pickedUpAt) {
        const hour = order.pickedUpAt.toDate().getHours();
        hourCounts[hour]++;
      }
    });

    return hourCounts.map((count, hour) => ({ hour, count }));
  }

  private async getDeliveryPersonsStats(zoneId: string) {
    const deliveryPersonsSnapshot = await db.collection('deliveryPersons')
      .where('zoneId', '==', zoneId)
      .get();

    return deliveryPersonsSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
  }
}

export const zoneService = new ZoneService();
