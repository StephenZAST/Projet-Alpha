import { execSync } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

async function generatePrismaSchema() {
  try {
    console.log('🔄 Starting Prisma schema generation...');

    const schemaPath = path.join(__dirname, '../../prisma/schema.prisma');
    
    // 1. Backup and remove existing schema if it exists
    if (fs.existsSync(schemaPath)) {
      const backupPath = `${schemaPath}.backup`;
      console.log('📦 Backing up existing schema...');
      fs.copyFileSync(schemaPath, backupPath);
      
      // Utiliser la commande Windows pour supprimer le fichier
      execSync('del /f /q "' + schemaPath.replace(/\//g, '\\') + '"', { stdio: 'inherit' });
    }

    // 2. Initialize new schema
    console.log('📝 Initializing new schema...');
    execSync('npx prisma init', { stdio: 'inherit' });

    // 3. Pull fresh schema from database
    console.log('🔄 Pulling schema from database...');
    execSync('npx prisma db pull', { stdio: 'inherit' });

    // 4. Format the schema
    console.log('💅 Formatting schema...');
    execSync('npx prisma format', { stdio: 'inherit' });

    // 5. Generate Prisma Client
    console.log('⚙️ Generating Prisma Client...');
    execSync('npx prisma generate', { stdio: 'inherit' });

    console.log('✅ Schema generation completed successfully');
    console.log('\nNext steps:');
    console.log('1. Review the generated schema in prisma/schema.prisma');
    console.log('2. Run `npx prisma studio` to view your data');
    
  } catch (error) {
    console.error('❌ Schema generation failed:', error);
    process.exit(1);
  }
}

generatePrismaSchema();
