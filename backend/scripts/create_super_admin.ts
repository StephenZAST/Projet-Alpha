import * as dotenv from 'dotenv';
import { createClient } from '@supabase/supabase-js';
import bcrypt from 'bcryptjs';

dotenv.config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseKey) {
  throw new Error('SUPABASE_URL and SUPABASE_SERVICE_KEY must be set in the .env file');
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function createSuperAdmin() {
  const email = 'zasteph300@gmail.com';
  const password = 'superadminpassword';
  const hashedPassword = await bcrypt.hash(password, 10);

  const { data, error } = await supabase
    .from('users')
    .insert([
      {
        email: email,
        password: hashedPassword,
        first_name: 'Super',
        last_name: 'Admin',
        role: 'SUPER_ADMIN',
        created_at: new Date(),
        updated_at: new Date()
      }
    ])
    .select()
    .single();

  if (error) {
    console.error('Error creating Super Admin:', error.message);
    return;
  }

  console.log('Super Admin created successfully:', data);
  console.log('Login credentials:');
  console.log('Email:', email);
  console.log('Password:', password);
}

createSuperAdmin().catch(console.error);
