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

interface DBFunction {
  function_name: string;
  type: string;
  source_code: string;
  description: string;
}

interface DBTrigger {
  trigger_name: string;
  trigger_event: string;
  table_name: string;
  trigger_definition: string;
  trigger_timing: string;
}

async function migrateDatabaseFunctions() {
  try {
    console.log('🚀 Starting database functions migration...');

    // 1. Create necessary extensions
    await prisma.$executeRaw`
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
      CREATE EXTENSION IF NOT EXISTS "pgcrypto";
    `;

    // 2. Read definition files
    const functionsPath = path.join(__dirname, '../../prisma/db_functions/functions.json');
    const triggersPath = path.join(__dirname, '../../prisma/db_functions/triggers.json');

    if (!fs.existsSync(functionsPath) || !fs.existsSync(triggersPath)) {
      throw new Error('Function or trigger definition files not found!');
    }

    const functions: DBFunction[] = JSON.parse(fs.readFileSync(functionsPath, 'utf8'));
    const triggers: DBTrigger[] = JSON.parse(fs.readFileSync(triggersPath, 'utf8'));

    // 3. Drop existing functions and triggers
    console.log('🗑️ Cleaning existing objects...');
    await cleanExistingObjects();

    // 4. Migrate functions
    console.log('📦 Migrating functions...');
    const functionResults = await migrateFunctions(functions);

    // 5. Migrate triggers
    console.log('🔄 Migrating triggers...');
    const triggerResults = await migrateTriggers(triggers);

    // 6. Generate and save report
    const report = generateMigrationReport(functionResults, triggerResults);
    const reportPath = path.join(__dirname, '../../prisma/db_functions/migration_report.json');
    fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));

    console.log('✅ Migration completed successfully');
    console.log(`📝 Report saved to: ${reportPath}`);

  } catch (error) {
    console.error('❌ Migration failed:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

async function cleanExistingObjects() {
  const dropFunctions = await prisma.$queryRaw`
    DO $$ 
    DECLARE 
      func record;
    BEGIN 
      FOR func IN (SELECT ns.nspname, p.proname, pg_get_function_identity_arguments(p.oid) AS args
                   FROM pg_proc p 
                   JOIN pg_namespace ns ON p.pronamespace = ns.oid 
                   WHERE ns.nspname = 'public') 
      LOOP
        EXECUTE 'DROP FUNCTION IF EXISTS ' || quote_ident(func.nspname) || '.' || 
                quote_ident(func.proname) || '(' || func.args || ') CASCADE';
      END LOOP;
    END $$;
  `;

  const dropTriggers = await prisma.$queryRaw`
    DO $$ 
    DECLARE 
      trig record;
    BEGIN 
      FOR trig IN (SELECT tgname, relname 
                   FROM pg_trigger 
                   JOIN pg_class ON tgrelid = pg_class.oid 
                   WHERE tgisinternal = false)
      LOOP
        EXECUTE 'DROP TRIGGER IF EXISTS ' || quote_ident(trig.tgname) || 
                ' ON ' || quote_ident(trig.relname) || ' CASCADE';
      END LOOP;
    END $$;
  `;
}

async function migrateFunctions(functions: DBFunction[]) {
  const results = [];
  for (const func of functions) {
    try {
      await prisma.$executeRawUnsafe(func.source_code);
      results.push({ name: func.function_name, status: 'success' });
    } catch (error: any) {
      results.push({ name: func.function_name, status: 'error', error: error.message });
    }
  }
  return results;
}

async function migrateTriggers(triggers: DBTrigger[]) {
  const results = [];
  for (const trigger of triggers) {
    try {
      const triggerSQL = `
        CREATE TRIGGER ${trigger.trigger_name}
        ${trigger.trigger_timing} ${trigger.trigger_event} ON ${trigger.table_name}
        FOR EACH ROW
        ${trigger.trigger_definition}
      `;
      await prisma.$executeRawUnsafe(triggerSQL);
      results.push({ name: trigger.trigger_name, status: 'success' });
    } catch (error: any) {
      results.push({ name: trigger.trigger_name, status: 'error', error: error.message });
    }
  }
  return results;
}

function generateMigrationReport(functionResults: any[], triggerResults: any[]) {
  return {
    timestamp: new Date().toISOString(),
    functions: {
      total: functionResults.length,
      successful: functionResults.filter(r => r.status === 'success').length,
      failed: functionResults.filter(r => r.status === 'error').length,
      details: functionResults
    },
    triggers: {
      total: triggerResults.length,
      successful: triggerResults.filter(r => r.status === 'success').length,
      failed: triggerResults.filter(r => r.status === 'error').length,
      details: triggerResults
    }
  };
}

export { migrateDatabaseFunctions };
