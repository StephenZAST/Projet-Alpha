import { supabase } from '../../config/supabase';
import { AppError, errorCodes } from '../../utils/errors';

export interface ZoneStats {
  zoneId: string;
  period: string;
  totalOrders: number;
  totalRevenue: number;
  averageOrderValue: number;
  deliverySuccessRate: number;
  averageDeliveryTime: number;
}

// Use Supabase to store zone stats data
const zoneStatsTable = 'zoneStats';

// Function to get zone stats data
export async function getZoneStats(id: string): Promise<ZoneStats | null> {
  const { data, error } = await supabase.from(zoneStatsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch zone stats', 'INTERNAL_SERVER_ERROR');
  }

  return data as ZoneStats;
}

// Function to create zone stats
export async function createZoneStats(statsData: ZoneStats): Promise<ZoneStats> {
  const { data, error } = await supabase.from(zoneStatsTable).insert([statsData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create zone stats', 'INTERNAL_SERVER_ERROR');
  }

  return data as ZoneStats;
}

// Function to update zone stats
export async function updateZoneStats(id: string, statsData: Partial<ZoneStats>): Promise<ZoneStats> {
  const currentStats = await getZoneStats(id);

  if (!currentStats) {
    throw new AppError(404, 'Zone stats not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(zoneStatsTable).update(statsData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update zone stats', 'INTERNAL_SERVER_ERROR');
  }

  return data as ZoneStats;
}

// Function to delete zone stats
export async function deleteZoneStats(id: string): Promise<void> {
  const stats = await getZoneStats(id);

  if (!stats) {
    throw new AppError(404, 'Zone stats not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(zoneStatsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete zone stats', 'INTERNAL_SERVER_ERROR');
  }
}
