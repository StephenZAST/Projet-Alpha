import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_KEY!
);

async function setupDatabaseFunctions() {
  try {
    console.log('🔧 Creating database functions...');

    const { error } = await supabase
      .rpc('create_sql_function', {
        function_name: 'get_table_structure',
        function_definition: `
          CREATE OR REPLACE FUNCTION get_table_structure(table_name text)
          RETURNS TABLE (
            column_name text,
            data_type text,
            is_nullable text,
            column_default text
          ) AS $$
          BEGIN
            RETURN QUERY
            SELECT 
              c.column_name::text,
              c.data_type::text,
              c.is_nullable::text,
              c.column_default::text
            FROM information_schema.columns c
            WHERE c.table_schema = 'public'
              AND c.table_name = $1
            ORDER BY c.ordinal_position;
          END;
          $$ LANGUAGE plpgsql;
        `
      });

    if (error) {
      throw error;
    }

    console.log('✅ Database functions created successfully');
  } catch (error) {
    console.error('❌ Failed to create database functions:', error);
  }
}

setupDatabaseFunctions();
