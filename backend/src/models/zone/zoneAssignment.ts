import { supabase } from '../../config/supabase';
import { AppError, errorCodes } from '../../utils/errors';

export interface ZoneAssignment {
  id?: string;
  zoneId: string;
  deliveryPersonId: string;
  startTime: string;
  endTime: string;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

// Use Supabase to store zone assignment data
const zoneAssignmentsTable = 'zoneAssignments';

// Function to get zone assignment data
export async function getZoneAssignment(id: string): Promise<ZoneAssignment | null> {
  const { data, error } = await supabase.from(zoneAssignmentsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch zone assignment', 'INTERNAL_SERVER_ERROR');
  }

  return data as ZoneAssignment;
}

// Function to create zone assignment
export async function createZoneAssignment(assignmentData: ZoneAssignment): Promise<ZoneAssignment> {
  const { data, error } = await supabase.from(zoneAssignmentsTable).insert([assignmentData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create zone assignment', 'INTERNAL_SERVER_ERROR');
  }

  return data as ZoneAssignment;
}

// Function to update zone assignment
export async function updateZoneAssignment(id: string, assignmentData: Partial<ZoneAssignment>): Promise<ZoneAssignment> {
  const currentAssignment = await getZoneAssignment(id);

  if (!currentAssignment) {
    throw new AppError(404, 'Zone assignment not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(zoneAssignmentsTable).update(assignmentData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update zone assignment', 'INTERNAL_SERVER_ERROR');
  }

  return data as ZoneAssignment;
}

// Function to delete zone assignment
export async function deleteZoneAssignment(id: string): Promise<void> {
  const assignment = await getZoneAssignment(id);

  if (!assignment) {
    throw new AppError(404, 'Zone assignment not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(zoneAssignmentsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete zone assignment', 'INTERNAL_SERVER_ERROR');
  }
}
