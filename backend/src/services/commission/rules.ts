import { createClient } from '@supabase/supabase-js';
import { CommissionRule } from '../../models/commission';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const commissionRulesTable = 'commissionRules';

export async function getCommissionRule(id: string): Promise<CommissionRule | null> {
  try {
    const { data, error } = await supabase.from(commissionRulesTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch commission rule', errorCodes.DATABASE_ERROR);
    }

    return data as CommissionRule;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch commission rule', errorCodes.DATABASE_ERROR);
  }
}

export async function createCommissionRule(ruleData: CommissionRule): Promise<CommissionRule> {
  try {
    const { data, error } = await supabase.from(commissionRulesTable).insert([ruleData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create commission rule', errorCodes.DATABASE_ERROR);
    }

    return data as CommissionRule;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create commission rule', errorCodes.DATABASE_ERROR);
  }
}

export async function updateCommissionRule(id: string, ruleData: Partial<CommissionRule>): Promise<CommissionRule> {
  try {
    const currentRule = await getCommissionRule(id);

    if (!currentRule) {
      throw new AppError(404, 'Commission rule not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(commissionRulesTable).update(ruleData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update commission rule', errorCodes.DATABASE_ERROR);
    }

    return data as CommissionRule;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update commission rule', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteCommissionRule(id: string): Promise<void> {
  try {
    const rule = await getCommissionRule(id);

    if (!rule) {
      throw new AppError(404, 'Commission rule not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(commissionRulesTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete commission rule', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete commission rule', errorCodes.DATABASE_ERROR);
  }
}
