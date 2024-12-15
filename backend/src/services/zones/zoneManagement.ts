import { createClient } from '@supabase/supabase-js';
import { Zone, ZoneStatus, Location } from '../../models/zone';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const zonesTable = 'zones';

/**
 * Get zone by id
 */
export async function getZone(id: string): Promise<Zone | null> {
  try {
    const { data, error } = await supabase.from(zonesTable).select('*').eq('id', id).single();

    if (error) {
      if (error.status === 404) {
        return null;
      }
      throw new AppError(500, 'Failed to fetch zone', errorCodes.DATABASE_ERROR);
    }

    return data as Zone;
  } catch (error) {
    console.error('Error fetching zone:', error);
    throw error;
  }
}

/**
 * Create a new zone
 */
export async function createZone(zoneData: Omit<Zone, 'id'>): Promise<Zone> {
  try {
    const { data, error } = await supabase.from(zonesTable).insert([zoneData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create zone', errorCodes.DATABASE_ERROR);
    }

    return { ...zoneData, id: data.id } as Zone;
  } catch (error) {
    console.error('Error creating zone:', error);
    throw error;
  }
}

/**
 * Update a zone
 */
export async function updateZone(id: string, zoneData: Partial<Zone>): Promise<Zone> {
  try {
    const currentZone = await getZone(id);

    if (!currentZone) {
      throw new AppError(404, 'Zone not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(zonesTable).update(zoneData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update zone', errorCodes.DATABASE_ERROR);
    }

    return { ...currentZone, ...zoneData } as Zone;
  } catch (error) {
    console.error('Error updating zone:', error);
    throw error;
  }
}

/**
 * Delete a zone
 */
export async function deleteZone(id: string): Promise<void> {
  try {
    const zone = await getZone(id);

    if (!zone) {
      throw new AppError(404, 'Zone not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(zonesTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete zone', errorCodes.DATABASE_ERROR);
    }
  } catch (error) {
    console.error('Error deleting zone:', error);
    throw error;
  }
}
