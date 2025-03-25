import { migrateDatabaseFunctions } from './migrateFunctions';
import { validateDatabaseRelations } from './validateRelations';
import { compareAndSync } from './compareAndSync';

async function runMigration() {
  try {
    console.log('🚀 Starting complete database migration process...');

    // 1. Migrate functions and triggers
    console.log('\n📦 Step 1: Migrating functions and triggers...');
    await migrateDatabaseFunctions();

    // 2. Sync data from Supabase to Neon
    console.log('\n📊 Step 2: Syncing data from Supabase to Neon...');
    await compareAndSync();

    // 3. Validate database relations
    console.log('\n🔍 Step 3: Validating database relations...');
    const validationReport = await validateDatabaseRelations();

    console.log('\n✅ Migration process completed successfully!');
    
    // Check for any validation issues
    if (validationReport.summary.missingRelations > 0) {
      console.warn(`⚠️  Warning: Found ${validationReport.summary.missingRelations} missing relations`);
    }

  } catch (error) {
    console.error('❌ Migration process failed:', error);
    process.exit(1);
  }
}

runMigration();
