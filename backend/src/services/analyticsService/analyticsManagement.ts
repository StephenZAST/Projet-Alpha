import { createClient } from '@supabase/supabase-js';
import { RevenueMetrics, CustomerMetrics, AffiliateMetrics } from '../../models/analytics';
import { AppError, errorCodes } from '../../utils/errors';

const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const analyticsTable = 'analytics';

export async function getAnalytics(id: string): Promise<RevenueMetrics | CustomerMetrics | AffiliateMetrics | null> {
  try {
    const { data, error } = await supabase.from(analyticsTable).select('*').eq('id', id).single();

    if (error) {
      throw new AppError(500, 'Failed to fetch analytics', errorCodes.DATABASE_ERROR);
    }

    return data as RevenueMetrics | CustomerMetrics | AffiliateMetrics;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to fetch analytics', errorCodes.DATABASE_ERROR);
  }
}

export async function createAnalytics(analyticsData: RevenueMetrics | CustomerMetrics | AffiliateMetrics): Promise<RevenueMetrics | CustomerMetrics | AffiliateMetrics> {
  try {
    const { data, error } = await supabase.from(analyticsTable).insert([analyticsData]).select().single();

    if (error) {
      throw new AppError(500, 'Failed to create analytics', errorCodes.DATABASE_ERROR);
    }

    return data as RevenueMetrics | CustomerMetrics | AffiliateMetrics;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to create analytics', errorCodes.DATABASE_ERROR);
  }
}

export async function updateAnalytics(id: string, analyticsData: Partial<RevenueMetrics | CustomerMetrics | AffiliateMetrics>): Promise<RevenueMetrics | CustomerMetrics | AffiliateMetrics> {
  try {
    const currentAnalytics = await getAnalytics(id);

    if (!currentAnalytics) {
      throw new AppError(404, 'Analytics not found', errorCodes.NOT_FOUND);
    }

    const { data, error } = await supabase.from(analyticsTable).update(analyticsData).eq('id', id).select().single();

    if (error) {
      throw new AppError(500, 'Failed to update analytics', errorCodes.DATABASE_ERROR);
    }

    return data as RevenueMetrics | CustomerMetrics | AffiliateMetrics;
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to update analytics', errorCodes.DATABASE_ERROR);
  }
}

export async function deleteAnalytics(id: string): Promise<void> {
  try {
    const analytics = await getAnalytics(id);

    if (!analytics) {
      throw new AppError(404, 'Analytics not found', errorCodes.NOT_FOUND);
    }

    const { error } = await supabase.from(analyticsTable).delete().eq('id', id);

    if (error) {
      throw new AppError(500, 'Failed to delete analytics', errorCodes.DATABASE_ERROR);
    }
  } catch (err) {
    if (err instanceof AppError) {
      throw err;
    }
    throw new AppError(500, 'Failed to delete analytics', errorCodes.DATABASE_ERROR);
  }
}
