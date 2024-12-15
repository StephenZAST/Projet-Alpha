import { createClient } from '@supabase/supabase-js';
import { Zone, ZoneStatus, Location } from '../models/zone';
import { AppError, errorCodes } from '../utils/errors';
import { getZone, createZone, updateZone, deleteZone } from './zones/zoneManagement';
import { getZoneAssignment, createZoneAssignment, updateZoneAssignment, deleteZoneAssignment } from './zones/zoneAssignmentManagement';
import { getZoneCapacity, createZoneCapacity, updateZoneCapacity, deleteZoneCapacity } from './zones/zoneCapacityManagement';
import { getZoneStatistics } from './zones/zoneStatistics';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const zonesTable = 'zones';
const zoneAssignmentsTable = 'zoneAssignments';
const zoneCapacitiesTable = 'zoneCapacities';
const zoneStatsTable = 'zoneStats';

export class ZonesService {
  private zonesRef = supabase.from(zonesTable);
  private zoneAssignmentsRef = supabase.from(zoneAssignmentsTable);
  private zoneCapacitiesRef = supabase.from(zoneCapacitiesTable);
  private zoneStatsRef = supabase.from(zoneStatsTable);

  /**
   * Create a new zone
   */
  async createZone(zoneData: Omit<Zone, 'id'>): Promise<Zone> {
    return createZone(zoneData);
  }

  /**
   * Get zone by id
   */
  async getZoneById(zoneId: string): Promise<Zone | null> {
    return getZone(zoneId);
  }

  /**
   * Get all zones
   */
  async getAllZones(options: {
    name?: string;
    isActive?: boolean;
    deliveryPersonId?: string;
    location?: any;
    page?: number;
    limit?: number;
  } = {}): Promise<Zone[]> {
    try {
      let query = this.zonesRef.select('*');

      if (options.name) {
        query = query.eq('name', options.name);
      }

      if (options.isActive !== undefined) {
        query = query.eq('isActive', options.isActive);
      }

      if (options.deliveryPersonId) {
        query = query.eq('deliveryPersonId', options.deliveryPersonId);
      }

      if (options.page && options.limit) {
        const offset = (options.page - 1) * options.limit;
        query = query.range(offset, offset + options.limit - 1);
      }

      const { data, error } = await query;

      if (error) {
        throw new AppError(500, 'Failed to fetch zones', errorCodes.DATABASE_ERROR);
      }

      return data.map(doc => ({ id: doc.id, ...doc } as Zone));
    } catch (error) {
      console.error('Error fetching zones:', error);
      throw error;
    }
  }

  /**
   * Update a zone
   */
  async updateZone(zoneId: string, updates: Partial<Zone>): Promise<boolean> {
    try {
      await this.zonesRef.update({
        ...updates,
        updatedAt: new Date().toISOString(),
      }).eq('id', zoneId);

      return true;
    } catch (error) {
      console.error('Error updating zone:', error);
      throw new AppError(500, 'Failed to update zone', errorCodes.DATABASE_ERROR);
    }
  }

  /**
   * Delete a zone
   */
  async deleteZone(zoneId: string): Promise<boolean> {
    try {
      const zone = await this.getZoneById(zoneId);

      if (!zone) {
        throw new AppError(404, 'Zone not found', errorCodes.NOT_FOUND);
      }

      const { data: activeOrders, error: ordersError } = await supabase
        .from('orders')
        .select('*')
        .eq('zoneId', zoneId)
        .in('status', ['pending', 'processing', 'assigned']);

      if (ordersError) {
        throw new AppError(500, 'Failed to fetch orders', errorCodes.DATABASE_ERROR);
      }

      if (activeOrders.length > 0) {
        throw new AppError(400, 'Cannot delete zone with active orders', errorCodes.ZONE_HAS_ACTIVE_ORDERS);
      }

      await this.zonesRef.delete().eq('id', zoneId);

      return true;
    } catch (error) {
      console.error('Error deleting zone:', error);
      throw error;
    }
  }

  /**
   * Assign delivery person to a zone
   */
  async assignDeliveryPerson(zoneId: string, deliveryPersonId: string): Promise<boolean> {
    try {
      const zone = await this.getZoneById(zoneId);

      if (!zone) {
        throw new AppError(404, 'Zone not found', errorCodes.NOT_FOUND);
      }

      const { data: deliveryPerson, error: deliveryPersonError } = await supabase
        .from('deliveryPersons')
        .select('*')
        .eq('id', deliveryPersonId)
        .single();

      if (deliveryPersonError) {
        throw new AppError(404, 'Delivery person not found', errorCodes.NOT_FOUND);
      }

      if (deliveryPerson.status !== 'available') {
        throw new AppError(400, 'Delivery person is not available', errorCodes.DELIVERY_PERSON_UNAVAILABLE);
      }

      await Promise.all([
        this.zonesRef.update({ deliveryPersonId, updatedAt: new Date().toISOString() }).eq('id', zoneId),
        supabase.from('deliveryPersons').update({ zoneId, status: 'assigned', updatedAt: new Date().toISOString() }).eq('id', deliveryPersonId)
      ]);

      return true;
    } catch (error) {
      console.error('Error assigning delivery person to zone:', error);
      throw new AppError(500, 'Failed to assign delivery person', errorCodes.DATABASE_ERROR);
    }
  }

  /**
   * Get zone statistics
   */
  async getZoneStatistics(zoneId: string, startDate?: Date, endDate?: Date): Promise<{
    totalOrders: number;
    averageDeliveryTime: number;
    totalRevenue: number;
    busyHours: { hour: number; count: number }[];
    deliveryPersonsStats: any[];
    period: { start: string | null; end: string | null };
  }> {
    return getZoneStatistics(zoneId, startDate, endDate);
  }
}

export const zonesService = new ZonesService();
