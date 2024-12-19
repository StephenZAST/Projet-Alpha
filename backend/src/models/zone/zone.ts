import { supabase } from '../../config/supabase';
import { AppError, errorCodes } from '../../utils/errors';
import { OrderItem } from '../order';

export enum ZoneStatus {
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  FULL = 'FULL',
  MAINTENANCE = 'MAINTENANCE'
}

export interface Location {
  latitude: number;
  longitude: number;
  address: string;
}

export interface Zone {
  id?: string;
  name: string;
  description?: string;
  boundaries: Location[];
  deliveryFee: number;
  minimumOrderAmount: number;
  estimatedDeliveryTime: number; // en minutes
  isActive: boolean;
  maxOrders: number;
  currentOrders: number;
  status: ZoneStatus;
  specialInstructions?: string;
  createdAt: string;
  updatedAt: string;
}

// Use Supabase to store zone data
const zonesTable = 'zones';

// Function to get zone data
export async function getZone(id: string): Promise<Zone | null> {
  const { data, error } = await supabase.from(zonesTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch zone', 'INTERNAL_SERVER_ERROR');
  }

  return data as Zone;
}

// Function to create zone
export async function createZone(zoneData: Zone): Promise<Zone> {
  const { data, error } = await supabase.from(zonesTable).insert([zoneData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create zone', 'INTERNAL_SERVER_ERROR');
  }

  return data as Zone;
}

// Function to update zone
export async function updateZone(id: string, zoneData: Partial<Zone>): Promise<Zone> {
  const currentZone = await getZone(id);

  if (!currentZone) {
    throw new AppError(404, 'Zone not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(zonesTable).update(zoneData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update zone', 'INTERNAL_SERVER_ERROR');
  }

  return data as Zone;
}

// Function to delete zone
export async function deleteZone(id: string): Promise<void> {
  const zone = await getZone(id);

  if (!zone) {
    throw new AppError(404, 'Zone not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(zonesTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete zone', 'INTERNAL_SERVER_ERROR');
  }
}
