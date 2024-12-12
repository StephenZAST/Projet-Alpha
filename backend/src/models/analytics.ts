import supabase from '../config/supabase';
import { AppError, errorCodes } from '../utils/errors';

export interface Analytics {
  id?: string;
  adminId: string;
  date: string;
  metric: string;
  value: number;
  createdAt?: string;
  updatedAt?: string;
}

// Use Supabase to store analytics data
const analyticsTable = 'analytics';

// Function to get analytics data
export async function getAnalytics(id: string): Promise<Analytics | null> {
  const { data, error } = await supabase.from(analyticsTable).select('*').eq('id', id).single();

  if (error) {
    throw new AppError(500, 'Failed to fetch analytics', 'INTERNAL_SERVER_ERROR');
  }

  return data as Analytics;
}

// Function to create analytics
export async function createAnalytics(analyticsData: Analytics): Promise<Analytics> {
  const { data, error } = await supabase.from(analyticsTable).insert([analyticsData]).select().single();

  if (error) {
    throw new AppError(500, 'Failed to create analytics', 'INTERNAL_SERVER_ERROR');
  }

  return data as Analytics;
}

// Function to update analytics
export async function updateAnalytics(id: string, analyticsData: Partial<Analytics>): Promise<Analytics> {
  const currentAnalytics = await getAnalytics(id);

  if (!currentAnalytics) {
    throw new AppError(404, 'Analytics not found', errorCodes.NOT_FOUND);
  }

  const { data, error } = await supabase.from(analyticsTable).update(analyticsData).eq('id', id).select().single();

  if (error) {
    throw new AppError(500, 'Failed to update analytics', 'INTERNAL_SERVER_ERROR');
  }

  return data as Analytics;
}

// Function to delete analytics
export async function deleteAnalytics(id: string): Promise<void> {
  const analytics = await getAnalytics(id);

  if (!analytics) {
    throw new AppError(404, 'Analytics not found', errorCodes.NOT_FOUND);
  }

  const { error } = await supabase.from(analyticsTable).delete().eq('id', id);

  if (error) {
    throw new AppError(500, 'Failed to delete analytics', 'INTERNAL_SERVER_ERROR');
  }
}
