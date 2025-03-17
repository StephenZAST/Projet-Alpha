import { PrismaClient } from '@prisma/client';
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
import fetch from 'cross-fetch';

// Add fetch polyfill
global.fetch = fetch;

dotenv.config();

const DATABASE_URL = process.env.DATABASE_NEW_URL?.replace('postgres://', 'postgresql://');

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: DATABASE_URL
    },
  },
  log: ['query', 'error', 'warn'],
  errorFormat: 'pretty',
});

const supabase = createClient(
  process.env.SUPABASE_URL || '',
  process.env.SUPABASE_SERVICE_KEY || '',
  {
    auth: { persistSession: false },
    db: { schema: 'public' }
  }
);

async function testConnections() {
  console.log('🔍 Testing database connections...\n');
  console.log('Environment:', {
    supabaseUrl: process.env.SUPABASE_URL?.substring(0, 20) + '...',
    databaseUrl: DATABASE_URL?.substring(0, 20) + '...',
  });

  // Test Supabase
  try {
    console.log('\nTesting Supabase connection...');
    const { data, error } = await supabase.auth.getSession();
    
    if (error) throw error;
    console.log('✅ Supabase connection successful!');
    console.log('Session:', data);
  } catch (error: any) {
    console.error('❌ Supabase connection failed:', {
      message: error.message,
      details: error.details,
      stack: error.stack
    });
  }

  // Test Prisma
  try {
    console.log('\nTesting Prisma connection...');
    await prisma.$connect();
    
    // Simple query that doesn't depend on schema
    const result = await prisma.$queryRaw`SELECT current_timestamp`;
    console.log('✅ Prisma connection successful!');
    console.log('Database timestamp:', result);
  } catch (error: any) {
    console.error('❌ Prisma connection failed:', {
      message: error.message,
      code: error.code,
      meta: error.meta,
      clientVersion: error.clientVersion,
    });
    
    // Additional connection info
    console.log('\nConnection details:');
    console.log('Database URL format:', DATABASE_URL?.replace(/:[^:@]+@/, ':****@'));
  } finally {
    await prisma.$disconnect();
  }
}

testConnections()
  .catch(console.error)
  .finally(() => process.exit(0));
