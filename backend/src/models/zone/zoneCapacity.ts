import { supabase } from '../../config/supabase';
import { AppError, errorCodes } from '../../utils/errors';

export interface TimeSlot {
  startTime: string; // Format: "HH:mm"
  endTime: string; // Format: "HH:mm"
  maxOrders: number;
  currentOrders: number;
  isAvailable: boolean;
}

export interface ZoneCapacity {
  id?: string;
  zoneId: string;
  date: string;
  maxOrders: number;
  currentOrders: number;
  timeSlots: TimeSlot[];
}

// Use Supabase to store zone capacity data
const zoneCapacitiesTable = 'zoneCapacities';

// Function to get zone capacity data
export async function getZoneCapacity(id: string): Promise<ZoneCapacity | null> {
  const { data, error } = await supabase.from(zoneCapacitiesTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch zone capacity', 'INTERNAL_SERVER_ERROR');
  }

  return data as ZoneCapacity;
}

// Function to create zone capacity
export async function createZoneCapacity(capacityData: ZoneCapacity): Promise<ZoneCapacity> {
  const { data, error } = await supabase.from(zoneCapacitiesTable).insert([capacityData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create zone capacity', 'INTERNAL_SERVER_ERROR');
  }

  return data as ZoneCapacity;
}

// Function to update zone capacity
export async function updateZoneCapacity(id: string, capacityData: Partial<ZoneCapacity>): Promise<ZoneCapacity> {
  const currentCapacity = await getZoneCapacity(id);

  if (!currentCapacity) {
    throw new AppError(404, 'Zone capacity not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(zoneCapacitiesTable).update(capacityData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update zone capacity', 'INTERNAL_SERVER_ERROR');
  }

  return data as ZoneCapacity;
}

// Function to delete zone capacity
export async function deleteZoneCapacity(id: string): Promise<void> {
  const capacity = await getZoneCapacity(id);

  if (!capacity) {
    throw new AppError(404, 'Zone capacity not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(zoneCapacitiesTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete zone capacity', 'INTERNAL_SERVER_ERROR');
  }
}
