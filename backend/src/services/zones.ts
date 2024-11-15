import { db } from './firebase';
import { Zone, ZoneStatus } from '../models/zone';
import { AppError, errorCodes } from '../utils/errors';
import { GeoPoint } from 'firebase-admin/firestore';

export async function createZone(zone: Zone): Promise<Zone> {
  try {
    const zoneRef = await db.collection('zones').add({
      ...zone,
      creationDate: new Date(),
      status: ZoneStatus.ACTIVE,
      lastUpdated: new Date()
    });
    
    return { ...zone, id: zoneRef.id };
  } catch (error) {
    console.error('Error creating zone:', error);
    throw new AppError(errorCodes.ZONE_CREATION_FAILED, 'Failed to create zone');
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
    throw new AppError(errorCodes.ZONE_FETCH_FAILED, 'Failed to fetch zone');
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
    throw new AppError(errorCodes.ZONES_FETCH_FAILED, 'Failed to fetch zones');
  }
}

export async function updateZone(zoneId: string, updates: Partial<Zone>): Promise<boolean> {
  try {
    await db.collection('zones').doc(zoneId).update({
      ...updates,
      lastUpdated: new Date()
    });
    
    return true;
  } catch (error) {
    console.error('Error updating zone:', error);
    throw new AppError(errorCodes.ZONE_UPDATE_FAILED, 'Failed to update zone');
  }
}

export async function deleteZone(zoneId: string): Promise<boolean> {
  try {
    // Vérifier s'il y a des commandes actives dans la zone
    const activeOrders = await db.collection('orders')
      .where('zoneId', '==', zoneId)
      .where('status', 'in', ['PENDING', 'IN_PROGRESS'])
      .limit(1)
      .get();

    if (!activeOrders.empty) {
      throw new AppError(
        errorCodes.ZONE_HAS_ACTIVE_ORDERS,
        'Cannot delete zone with active orders'
      );
    }

    // Marquer la zone comme inactive au lieu de la supprimer
    await db.collection('zones').doc(zoneId).update({
      status: ZoneStatus.INACTIVE,
      lastUpdated: new Date()
    });

    return true;
  } catch (error) {
    console.error('Error deleting zone:', error);
    throw new AppError(errorCodes.ZONE_DELETE_FAILED, 'Failed to delete zone');
  }
}

export async function assignDeliveryPerson(
  zoneId: string,
  deliveryPersonId: string
): Promise<boolean> {
  try {
    // Vérifier si le livreur existe
    const deliveryPersonDoc = await db.collection('users').doc(deliveryPersonId).get();
    if (!deliveryPersonDoc.exists) {
      throw new AppError(
        errorCodes.DELIVERY_PERSON_NOT_FOUND,
        'Delivery person not found'
      );
    }

    // Mettre à jour la zone avec le nouveau livreur
    await db.collection('zones').doc(zoneId).update({
      deliveryPersonIds: db.FieldValue.arrayUnion(deliveryPersonId),
      lastUpdated: new Date()
    });

    return true;
  } catch (error) {
    console.error('Error assigning delivery person:', error);
    throw new AppError(
      errorCodes.DELIVERY_PERSON_ASSIGNMENT_FAILED,
      'Failed to assign delivery person to zone'
    );
  }
}

export async function getZoneStatistics(
  zoneId: string,
  startDate?: Date,
  endDate?: Date
) {
  try {
    let query = db.collection('orders').where('zoneId', '==', zoneId);

    if (startDate) {
      query = query.where('creationDate', '>=', startDate);
    }
    if (endDate) {
      query = query.where('creationDate', '<=', endDate);
    }

    const ordersSnapshot = await query.get();
    const orders = ordersSnapshot.docs.map(doc => doc.data());

    // Calculer les statistiques
    const stats = {
      totalOrders: orders.length,
      completedOrders: orders.filter(o => o.status === 'COMPLETED').length,
      cancelledOrders: orders.filter(o => o.status === 'CANCELLED').length,
      averageDeliveryTime: calculateAverageDeliveryTime(orders),
      totalRevenue: calculateTotalRevenue(orders),
      busyHours: calculateBusyHours(orders)
    };

    return stats;
  } catch (error) {
    console.error('Error fetching zone statistics:', error);
    throw new AppError(
      errorCodes.ZONE_STATS_FETCH_FAILED,
      'Failed to fetch zone statistics'
    );
  }
}

function calculateAverageDeliveryTime(orders: any[]): number {
  const completedOrders = orders.filter(
    o => o.status === 'COMPLETED' && o.completionDate && o.creationDate
  );

  if (completedOrders.length === 0) return 0;

  const totalTime = completedOrders.reduce((sum, order) => {
    const completionTime = order.completionDate.toDate().getTime() - 
                         order.creationDate.toDate().getTime();
    return sum + completionTime;
  }, 0);

  return totalTime / completedOrders.length / (1000 * 60 * 60); // Convertir en heures
}

function calculateTotalRevenue(orders: any[]): number {
  return orders.reduce((sum, order) => sum + (order.totalAmount || 0), 0);
}

function calculateBusyHours(orders: any[]): { hour: number; count: number }[] {
  const hourCounts = new Array(24).fill(0);

  orders.forEach(order => {
    if (order.creationDate) {
      const hour = order.creationDate.toDate().getHours();
      hourCounts[hour]++;
    }
  });

  return hourCounts.map((count, hour) => ({ hour, count }))
    .sort((a, b) => b.count - a.count);
}
