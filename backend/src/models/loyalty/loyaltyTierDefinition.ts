import supabase from '../../config/supabase';
import { AppError, errorCodes } from '../../utils/errors';

export interface LoyaltyTierDefinition {
  name: string;
  minimumPoints: number;
  benefits: {
    pointsMultiplier: number;
    additionalPerks: string[];
  };
}

// Use Supabase to store loyalty tier definition data
const loyaltyTierDefinitionsTable = 'loyaltyTierDefinitions';

// Function to get loyalty tier definition data
export async function getLoyaltyTierDefinition(name: string): Promise<LoyaltyTierDefinition | null> {
  const { data, error } = await supabase.from(loyaltyTierDefinitionsTable).select('*').eq('name', name).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch loyalty tier definition', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyTierDefinition;
}

// Function to create loyalty tier definition
export async function createLoyaltyTierDefinition(definitionData: LoyaltyTierDefinition): Promise<LoyaltyTierDefinition> {
  const { data, error } = await supabase.from(loyaltyTierDefinitionsTable).insert([definitionData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create loyalty tier definition', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyTierDefinition;
}

// Function to update loyalty tier definition
export async function updateLoyaltyTierDefinition(name: string, definitionData: Partial<LoyaltyTierDefinition>): Promise<LoyaltyTierDefinition> {
  const currentDefinition = await getLoyaltyTierDefinition(name);

  if (!currentDefinition) {
    throw new AppError(404, 'Loyalty tier definition not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(loyaltyTierDefinitionsTable).update(definitionData).eq('name', name).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update loyalty tier definition', 'INTERNAL_SERVER_ERROR');
  }

  return data as LoyaltyTierDefinition;
}

// Function to delete loyalty tier definition
export async function deleteLoyaltyTierDefinition(name: string): Promise<void> {
  const definition = await getLoyaltyTierDefinition(name);

  if (!definition) {
    throw new AppError(404, 'Loyalty tier definition not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(loyaltyTierDefinitionsTable).delete().eq('name', name);

  if (error) {
    throw new AppError(500, 'Failed to delete loyalty tier definition', 'INTERNAL_SERVER_ERROR');
  }
}
