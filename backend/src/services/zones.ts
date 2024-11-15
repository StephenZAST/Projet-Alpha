import { db } from './firebase';
import { Zone, ZoneStatus } from '../models/zone';
import { AppError, errorCodes } from '../utils/errors';
import { GeoPoint, FieldValue } from 'firebase-admin/firestore';

export async function createZone(zone: Zone): Promise<Zone> {
  try {
    const zoneRef = await db.collection('zones').add({
      ...zone,
      createdAt: new Date(),
      status: ZoneStatus.ACTIVE,
      updatedAt: new Date()
    });
    
    return { ...zone, id: zoneRef.id };
  } catch (error) {
    console.error('Error creating zone:', error);
    throw new AppError(500, 'Failed to create zone', errorCodes.ZONE_CREATION_FAILED);
  }
}

export async function getZoneById(zoneId: string): Promise<Zone | null> {
  try {
    const zoneDoc = await db.collection('zones').doc(zoneId).get();
    
    if (!zoneDoc.exists) {
      return null;
    }
    
    return { id: zoneDoc.id, ...zoneDoc.data() } as Zone;
  } catch (error) {
    console.error('Error fetching zone:', error);
    throw new AppError(500, 'Failed to fetch zone', errorCodes.ZONE_FETCH_FAILED);
  }
}

export async function getAllZones(): Promise<Zone[]> {
  try {
    const zonesSnapshot = await db.collection('zones')
      .where('status', '==', ZoneStatus.ACTIVE)
      .get();
    
    return zonesSnapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    } as Zone));
  } catch (error) {
    console.error('Error fetching zones:', error);
    throw new AppError(500, 'Failed to fetch zones', errorCodes.ZONES_FETCH_FAILED);
  }
}

export async function updateZone(zoneId: string, updates: Partial<Zone>): Promise<boolean> {
  try {
    await db.collection('zones').doc(zoneId).update({
      ...updates,
      updatedAt: new Date()
    });
    
    return true;
  } catch (error) {
    console.error('Error updating zone:', error);
    throw new AppError(500, 'Failed to update zone', errorCodes.ZONE_UPDATE_FAILED);
  }
}

export async function deleteZone(zoneId: string): Promise<boolean> {
  try {
    const zoneRef = db.collection('zones').doc(zoneId);
    const zoneDoc = await zoneRef.get();
    
    if (!zoneDoc.exists) {
      throw new AppError(404, 'Zone not found', errorCodes.ZONE_NOT_FOUND);
    }
    
    const zone = zoneDoc.data() as Zone;
    
    if (zone.currentOrders > 0) {
      throw new AppError(400, 'Cannot delete zone with active orders', errorCodes.ZONE_HAS_ACTIVE_ORDERS);
    }
    
    await zoneRef.update({
      status: ZoneStatus.INACTIVE,
      updatedAt: new Date()
    });
    
    return true;
  } catch (error) {
    console.error('Error deleting zone:', error);
    throw new AppError(500, 'Failed to delete zone', errorCodes.ZONE_DELETE_FAILED);
  }
}

export async function assignDeliveryPerson(
  zoneId: string,
  deliveryPersonId: string
): Promise<boolean> {
  try {
    const zoneRef = db.collection('zones').doc(zoneId);
    const zoneDoc = await zoneRef.get();
    
    if (!zoneDoc.exists) {
      throw new AppError(404, 'Zone not found', errorCodes.ZONE_NOT_FOUND);
    }
    
    const assignmentData = {
      zoneId,
      deliveryPersonId,
      startTime: new Date(),
      isActive: true,
      createdAt: new Date(),
      updatedAt: new Date()
    };
    
    await db.collection('zoneAssignments').add(assignmentData);
    
    await zoneRef.update({
      currentOrders: FieldValue.increment(1),
      updatedAt: new Date()
    });
    
    return true;
  } catch (error) {
    console.error('Error assigning delivery person:', error);
    throw new AppError(500, 'Failed to assign delivery person', errorCodes.ZONE_ASSIGNMENT_FAILED);
  }
}

export async function getZoneStatistics(
  zoneId: string,
  startDate?: Date,
  endDate?: Date
) {
  try {
    const zoneRef = db.collection('zones').doc(zoneId);
    const zoneDoc = await zoneRef.get();
    
    if (!zoneDoc.exists) {
      throw new AppError(404, 'Zone not found', errorCodes.ZONE_NOT_FOUND);
    }
    
    let ordersQuery = db.collection('orders').where('zoneId', '==', zoneId);
    
    if (startDate) {
      ordersQuery = ordersQuery.where('createdAt', '>=', startDate);
    }
    if (endDate) {
      ordersQuery = ordersQuery.where('createdAt', '<=', endDate);
    }
    
    const ordersSnapshot = await ordersQuery.get();
    const orders = ordersSnapshot.docs.map(doc => doc.data());
    
    return {
      totalOrders: orders.length,
      averageDeliveryTime: calculateAverageDeliveryTime(orders),
      totalRevenue: calculateTotalRevenue(orders),
      busyHours: calculateBusyHours(orders),
      deliveryPersons: await getDeliveryPersonsStats(zoneId)
    };
  } catch (error) {
    console.error('Error getting zone statistics:', error);
    throw new AppError(500, 'Failed to get zone statistics', errorCodes.ZONE_STATS_FAILED);
  }
}

function calculateAverageDeliveryTime(orders: any[]): number {
  if (orders.length === 0) return 0;
  
  const totalTime = orders.reduce((sum, order) => {
    if (order.deliveredAt && order.pickedUpAt) {
      const deliveryTime = order.deliveredAt.toDate().getTime() - order.pickedUpAt.toDate().getTime();
      return sum + deliveryTime;
    }
    return sum;
  }, 0);
  
  return totalTime / orders.length / (1000 * 60); // Convert to minutes
}

function calculateTotalRevenue(orders: any[]): number {
  return orders.reduce((sum, order) => sum + (order.total || 0), 0);
}

function calculateBusyHours(orders: any[]): { hour: number; count: number }[] {
  const hourCounts = new Array(24).fill(0);
  
  orders.forEach(order => {
    if (order.createdAt) {
      const hour = order.createdAt.toDate().getHours();
      hourCounts[hour]++;
    }
  });
  
  return hourCounts.map((count, hour) => ({ hour, count }));
}

async function getDeliveryPersonsStats(zoneId: string) {
  const assignmentsSnapshot = await db.collection('zoneAssignments')
    .where('zoneId', '==', zoneId)
    .where('isActive', '==', true)
    .get();
  
  return assignmentsSnapshot.docs.length;
}
