import supabase from '../../config/supabase';
import { AppError, errorCodes } from '../../utils/errors';

export enum LoyaltyEventType {
  POINTS_EARNED = 'POINTS_EARNED',
  POINTS_REDEEMED = 'POINTS_REDEEMED',
  REWARD_CREATED = 'REWARD_CREATED',
  REWARD_REDEEMED = 'REWARD_REDEEMED',
  REWARD_UPDATED = 'REWARD_UPDATED',
  REWARD_DELETED = 'REWARD_DELETED',
  TIER_UPGRADED = 'TIER_UPGRADED',
  TIER_DOWNGRADED = 'TIER_DOWNGRADED',
  POINTS_ADJUSTED = 'POINTS_ADJUSTED',
  POINTS_EXPIRED = 'POINTS_EXPIRED',
  ACCOUNT_CREATED = 'ACCOUNT_CREATED',
  ACCOUNT_UPDATED = 'ACCOUNT_UPDATED',
  PROGRAM_CREATED = 'PROGRAM_CREATED',
  PROGRAM_UPDATED = 'PROGRAM_UPDATED',
  PROGRAM_DELETED = 'PROGRAM_DELETED'
}

export interface LoyaltyEvent {
  id?: string;
  userId: string;
  type: LoyaltyEventType;
  details: string;
  metadata?: Record<string, any>;
  createdAt: string;
}

// Use Supabase to store loyalty event data
const loyaltyEventsTable = 'loyaltyEvents';

// Function to get loyalty event data
export async function getLoyaltyEvent(id: string): Promise<LoyaltyEvent | null> {
  const { data, error } = await supabase.from(loyaltyEventsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch loyalty event', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyEvent;
}

// Function to create loyalty event
export async function createLoyaltyEvent(eventData: LoyaltyEvent): Promise<LoyaltyEvent> {
  const { data, error } = await supabase.from(loyaltyEventsTable).insert([eventData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create loyalty event', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyEvent;
}

// Function to update loyalty event
export async function updateLoyaltyEvent(id: string, eventData: Partial<LoyaltyEvent>): Promise<LoyaltyEvent> {
  const currentEvent = await getLoyaltyEvent(id);

  if (!currentEvent) {
    throw new AppError(404, 'Loyalty event not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(loyaltyEventsTable).update(eventData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update loyalty event', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyEvent;
}

// Function to delete loyalty event
export async function deleteLoyaltyEvent(id: string): Promise<void> {
  const event = await getLoyaltyEvent(id);

  if (!event) {
    throw new AppError(404, 'Loyalty event not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(loyaltyEventsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete loyalty event', 'INTERNAL_SERVER_ERROR');
  }
}
