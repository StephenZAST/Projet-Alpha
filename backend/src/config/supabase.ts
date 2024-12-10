import { createClient } from '@supabase/supabase-js';

// Use the environment variable for the Supabase key
const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseServiceRoleKey = process.env.SUPABASE_KEY;

if (!supabaseServiceRoleKey) {
  throw new Error('SUPABASE_KEY environment variable not set.');
}

// Initialize the Supabase client with the service role key (bypasses RLS)
const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

export default supabase;
