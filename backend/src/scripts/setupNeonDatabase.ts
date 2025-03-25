import { PrismaClient } from '@prisma/client';
import * as fs from 'fs';
import * as path from 'path';
import dotenv from 'dotenv';

dotenv.config();

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.NEON_DB_URL
    }
  }
});

async function setupDatabase() {
  try {
    console.log('🔧 Setting up Neon database...');

    // Handle extensions separately first
    console.log('📦 Creating extensions...');
    const extensions = [
      'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"',
      'CREATE EXTENSION IF NOT EXISTS "pgcrypto"'
    ];

    for (const ext of extensions) {
      try {
        await prisma.$executeRawUnsafe(ext);
        console.log(`✅ Extension created: ${ext}`);
      } catch (error: any) {
        if (error.meta?.message?.includes('already exists')) {
          console.log(`ℹ️ Extension already exists: ${ext}`);
        } else {
          console.error(`❌ Failed to create extension:`, ext, error.message);
        }
      }
    }

    // Read and split SQL into individual statements
    const setupSQL = fs.readFileSync(
      path.join(__dirname, '../../sql/setup_database.sql'),
      'utf8'
    );

    const statements = setupSQL
      .split(/DO \$\$/)
      .filter(s => s.trim())
      .map(s => s.includes('END $$;') ? `DO $$${s}` : s.trim())
      .filter(s => !s.includes('CREATE EXTENSION'));

    // Execute each statement separately
    for (const statement of statements) {
      try {
        if (statement.trim()) {
          await prisma.$executeRawUnsafe(statement);
          console.log('✅ Executed:', statement.substring(0, 50) + '...');
        }
      } catch (error: any) {
        if (!error.message.includes('already exists')) {
          console.error('❌ Failed to execute:', {
            error: error.message,
            statement: statement.substring(0, 100)
          });
        }
      }
    }

    console.log('✅ Database setup completed');
  } catch (error) {
    console.error('❌ Setup failed:', error);
  } finally {
    await prisma.$disconnect();
  }
}

setupDatabase();
