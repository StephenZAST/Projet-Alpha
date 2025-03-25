import { execSync } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

async function applyPrismaSchema() {
  try {
    console.log('🔄 Applying Prisma schema...');

    // 1. Format schema
    console.log('💅 Formatting schema...');
    execSync('npx prisma format', { stdio: 'inherit' });

    // 2. Push schema changes to database
    console.log('🔼 Pushing schema to database...');
    execSync('npx prisma db push --accept-data-loss', { stdio: 'inherit' });

    // 3. Generate Prisma Client
    console.log('⚙️ Generating Prisma Client...');
    execSync('npx prisma generate', { stdio: 'inherit' });

    console.log('✅ Schema applied successfully');
    
  } catch (error) {
    console.error('❌ Schema application failed:', error);
    process.exit(1);
  }
}

applyPrismaSchema();
