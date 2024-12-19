import { createClient } from '@supabase/supabase-js';
import { ZoneAssignment } from '../../models/zone';
import { AppError, errorCodes } from '../../utils/errors';
import dotenv from 'dotenv';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL or SUPABASE_SERVICE_KEY environment variables not set.');
}

const supabase = createClient(supabaseUrl as string, supabaseKey as string);

const zoneAssignmentsTable = 'zoneAssignments';

/**
 * Get zone assignment by id
 */
export async function getZoneAssignment(id: string): Promise<ZoneAssignment | null> {
  try {
    const { data, error } = await supabase.from(zoneAssignmentsTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch zone assignment', errorCodes.DATABASE_ERROR);
    }

    if (!data) {
      return null;
    }

    return data as ZoneAssignment;
  } catch (error) {
    console.error('Error fetching zone assignment:', error);
    throw error;
  }
}

/**
 * Create a new zone assignment
 */
export async function createZoneAssignment(assignmentData: Omit<ZoneAssignment, 'id'>): Promise<ZoneAssignment> {
  try {
    const { data, error } = await supabase.from(zoneAssignmentsTable).insert([assignmentData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create zone assignment', errorCodes.DATABASE_ERROR);
    }

    if (!data) {
      throw new AppError(500, 'Failed to create zone assignment', errorCodes.DATABASE_ERROR);
    }

    return { ...assignmentData, id: data.id } as ZoneAssignment;
  } catch (error) {
    console.error('Error creating zone assignment:', error);
    throw error;
  }
}

/**
 * Update a zone assignment
 */
export async function updateZoneAssignment(id: string, assignmentData: Partial<ZoneAssignment>): Promise<ZoneAssignment> {
  try {
    const currentAssignment = await getZoneAssignment(id);

    if (!currentAssignment) {
      throw new AppError(404, 'Zone assignment not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(zoneAssignmentsTable).update(assignmentData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update zone assignment', errorCodes.DATABASE_ERROR);
    }

    if (!data) {
      throw new AppError(500, 'Failed to update zone assignment', errorCodes.DATABASE_ERROR);
    }

    return { ...currentAssignment, ...assignmentData } as ZoneAssignment;
  } catch (error) {
    console.error('Error updating zone assignment:', error);
    throw error;
  }
}

/**
 * Delete a zone assignment
 */
export async function deleteZoneAssignment(id: string): Promise<void> {
  try {
    const assignment = await getZoneAssignment(id);

    if (!assignment) {
      throw new AppError(404, 'Zone assignment not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(zoneAssignmentsTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete zone assignment', errorCodes.DATABASE_ERROR);
    }
  } catch (error) {
    console.error('Error deleting zone assignment:', error);
    throw error;
  }
}
