import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export interface Commission {
  id: string;
  affiliateId: string;
  clientId: string;         // ID du client apporté
  orderId: string;
  orderAmount: number;
  commissionAmount: number;
  status: 'PENDING' | 'APPROVED' | 'PAID';
  createdAt: string;
  approvedAt?: string;
  paidAt?: string;
}

export interface CommissionRule {
  id: string;
  name: string;
  description: string;
  type: 'PERCENTAGE';       // Simplifié à pourcentage uniquement
  value: number;            // Valeur du pourcentage
  minimumOrderValue: number;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

// Use Supabase to store commission data
const commissionsTable = 'commissions';
const commissionRulesTable = 'commissionRules';

// Function to get commission data
export async function getCommission(id: string): Promise<Commission | null> {
  const { data, error } = await supabase.from(commissionsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch commission', 'INTERNAL_SERVER_ERROR');
  }

  return data as Commission;
}

// Function to create commission
export async function createCommission(commissionData: Commission): Promise<Commission> {
  const { data, error } = await supabase.from(commissionsTable).insert([commissionData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create commission', 'INTERNAL_SERVER_ERROR');
  }

  return data as Commission;
}

// Function to update commission
export async function updateCommission(id: string, commissionData: Partial<Commission>): Promise<Commission> {
  const currentCommission = await getCommission(id);

  if (!currentCommission) {
    throw new AppError(404, 'Commission not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(commissionsTable).update(commissionData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update commission', 'INTERNAL_SERVER_ERROR');
  }

  return data as Commission;
}

// Function to delete commission
export async function deleteCommission(id: string): Promise<void> {
  const commission = await getCommission(id);

  if (!commission) {
    throw new AppError(404, 'Commission not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(commissionsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete commission', 'INTERNAL_SERVER_ERROR');
  }
}

// Function to get commission rule data
export async function getCommissionRule(id: string): Promise<CommissionRule | null> {
  const { data, error } = await supabase.from(commissionRulesTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch commission rule', 'INTERNAL_SERVER_ERROR');
  }

  return data as CommissionRule;
}

// Function to create commission rule
export async function createCommissionRule(ruleData: CommissionRule): Promise<CommissionRule> {
  const { data, error } = await supabase.from(commissionRulesTable).insert([ruleData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create commission rule', 'INTERNAL_SERVER_ERROR');
  }

  return data as CommissionRule;
}

// Function to update commission rule
export async function updateCommissionRule(id: string, ruleData: Partial<CommissionRule>): Promise<CommissionRule> {
  const currentRule = await getCommissionRule(id);

  if (!currentRule) {
    throw new AppError(404, 'Commission rule not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(commissionRulesTable).update(ruleData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update commission rule', 'INTERNAL_SERVER_ERROR');
  }

  return data as CommissionRule;
}

// Function to delete commission rule
export async function deleteCommissionRule(id: string): Promise<void> {
  const rule = await getCommissionRule(id);

  if (!rule) {
    throw new AppError(404, 'Commission rule not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(commissionRulesTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete commission rule', 'INTERNAL_SERVER_ERROR');
  }
}
