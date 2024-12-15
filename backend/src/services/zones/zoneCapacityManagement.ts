import { createClient } from '@supabase/supabase-js';
import { ZoneCapacity, TimeSlot } from '../../models/zone';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const zoneCapacitiesTable = 'zoneCapacities';

/**
 * Get zone capacity by id
 */
export async function getZoneCapacity(id: string): Promise<ZoneCapacity | null> {
  try {
    const { data, error } = await supabase.from(zoneCapacitiesTable).select('*').eq('id', id).single();

    if (error) {
      if (error.status === 404) {
        return null;
      }
      throw new AppError(500, 'Failed to fetch zone capacity', errorCodes.DATABASE_ERROR);
    }

    return data as ZoneCapacity;
  } catch (error) {
    console.error('Error fetching zone capacity:', error);
    throw error;
  }
}

/**
 * Create a new zone capacity
 */
export async function createZoneCapacity(capacityData: Omit<ZoneCapacity, 'id'>): Promise<ZoneCapacity> {
  try {
    const { data, error } = await supabase.from(zoneCapacitiesTable).insert([capacityData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create zone capacity', errorCodes.DATABASE_ERROR);
    }

    return { ...capacityData, id: data.id } as ZoneCapacity;
  } catch (error) {
    console.error('Error creating zone capacity:', error);
    throw error;
  }
}

/**
 * Update a zone capacity
 */
export async function updateZoneCapacity(id: string, capacityData: Partial<ZoneCapacity>): Promise<ZoneCapacity> {
  try {
    const currentCapacity = await getZoneCapacity(id);

    if (!currentCapacity) {
      throw new AppError(404, 'Zone capacity not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(zoneCapacitiesTable).update(capacityData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update zone capacity', errorCodes.DATABASE_ERROR);
    }

    return { ...currentCapacity, ...capacityData } as ZoneCapacity;
  } catch (error) {
    console.error('Error updating zone capacity:', error);
    throw error;
  }
}

/**
 * Delete a zone capacity
 */
export async function deleteZoneCapacity(id: string): Promise<void> {
  try {
    const capacity = await getZoneCapacity(id);

    if (!capacity) {
      throw new AppError(404, 'Zone capacity not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(zoneCapacitiesTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete zone capacity', errorCodes.DATABASE_ERROR);
    }
  } catch (error) {
    console.error('Error deleting zone capacity:', error);
    throw error;
  }
}
