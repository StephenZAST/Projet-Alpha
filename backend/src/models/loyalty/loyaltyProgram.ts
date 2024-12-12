import supabase from '../../config/supabase';
import { AppError, errorCodes } from '../../utils/errors';
import { LoyaltyTier } from './loyaltyAccount';

export interface LoyaltyProgram {
  id: string;
  clientId: string;
  points: number;
  tier: LoyaltyTier;
  referralCode: string;          // Code de parrainage personnel
  totalReferrals: number;
  createdAt: string;
  updatedAt: string;
}

// Use Supabase to store loyalty program data
const loyaltyProgramsTable = 'loyaltyPrograms';

// Function to get loyalty program data
export async function getLoyaltyProgram(id: string): Promise<LoyaltyProgram | null> {
  const { data, error } = await supabase.from(loyaltyProgramsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch loyalty program', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyProgram;
}

// Function to create loyalty program
export async function createLoyaltyProgram(programData: LoyaltyProgram): Promise<LoyaltyProgram> {
  const { data, error } = await supabase.from(loyaltyProgramsTable).insert([programData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create loyalty program', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyProgram;
}

// Function to update loyalty program
export async function updateLoyaltyProgram(id: string, programData: Partial<LoyaltyProgram>): Promise<LoyaltyProgram> {
  const currentProgram = await getLoyaltyProgram(id);

  if (!currentProgram) {
    throw new AppError(404, 'Loyalty program not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(loyaltyProgramsTable).update(programData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update loyalty program', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyProgram;
}

// Function to delete loyalty program
export async function deleteLoyaltyProgram(id: string): Promise<void> {
  const program = await getLoyaltyProgram(id);

  if (!program) {
    throw new AppError(404, 'Loyalty program not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(loyaltyProgramsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete loyalty program', 'INTERNAL_SERVER_ERROR');
  }
}
