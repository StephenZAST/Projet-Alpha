import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

// Use the environment variable for the Supabase key
const supabaseUrl = 'https://qlmqkxntdhaiuiupnhdf.supabase.co';
const supabaseServiceRoleKey = process.env.SUPABASE_KEY;

if (!supabaseUrl || !supabaseServiceRoleKey) {
  throw new Error('Supabase credentials not found in environment variables');
}

const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

export default supabase;
