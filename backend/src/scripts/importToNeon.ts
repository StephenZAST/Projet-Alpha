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

// Fonction pour nettoyer et formater le SQL
function sanitizeSQL(sql: string): string {
  // Retire les retours à la ligne Windows
  return sql.replace(/\r\n/g, '\n')
    // Retire les commentaires
    .replace(/--.*$/gm, '')
    // Normalise les espaces
    .replace(/\s+/g, ' ')
    .trim();
}

// Fonction pour extraire les blocs de fonction/procédure
function extractFunctionBlocks(sql: string): string[] {
  const blocks: string[] = [];
  let currentBlock = '';
  let depth = 0;

  const lines = sql.split('\n');
  for (const line of lines) {
    const trimmedLine = line.trim();
    
    if (trimmedLine.includes('CREATE OR REPLACE FUNCTION') || 
        trimmedLine.includes('CREATE OR REPLACE PROCEDURE')) {
      currentBlock = line + '\n';
      depth = 1;
      continue;
    }

    if (depth > 0) {
      currentBlock += line + '\n';
      if (trimmedLine.includes('BEGIN')) depth++;
      if (trimmedLine.includes('END;')) depth--;
      
      if (depth === 0) {
        blocks.push(currentBlock);
        currentBlock = '';
      }
    }
  }

  return blocks;
}

async function importFile(filePath: string) {
  console.log(`📄 Importing ${path.basename(filePath)}...`);
  const sql = fs.readFileSync(filePath, 'utf8');

  try {
    const fileName = path.basename(filePath);
    if (fileName === 'functions.sql' || fileName === 'procedures.sql') {
      // Traitement spécial pour les fonctions et procédures
      const blocks = extractFunctionBlocks(sql);
      for (const block of blocks) {
        try {
          const cleanBlock = sanitizeSQL(block);
          await prisma.$executeRawUnsafe(cleanBlock);
          console.log('✅ Function/Procedure created successfully');
        } catch (error: any) {
          console.error('❌ Failed to create function/procedure:', {
            error: error.message,
            block: block.substring(0, 100) + '...'
          });
        }
      }
    } else if (fileName === 'triggers.sql') {
      // Traitement spécial pour les triggers
      const triggers = sql.split(';').filter(t => t.trim());
      for (const trigger of triggers) {
        try {
          const cleanTrigger = sanitizeSQL(trigger);
          if (cleanTrigger) {
            await prisma.$executeRawUnsafe(cleanTrigger);
            console.log('✅ Trigger created successfully');
          }
        } catch (error: any) {
          console.error('❌ Failed to create trigger:', {
            error: error.message,
            trigger: trigger.substring(0, 100) + '...'
          });
        }
      }
    } else {
      // Traitement normal pour les tables
      const statements = sql
        .split(';')
        .map(s => sanitizeSQL(s))
        .filter(s => s);

      for (const statement of statements) {
        try {
          await prisma.$executeRawUnsafe(statement);
          console.log('✅ Statement executed successfully');
        } catch (error: any) {
          console.error('❌ Statement failed:', {
            statement: statement.substring(0, 100) + '...',
            error: error.message
          });
        }
      }
    }
  } catch (error) {
    console.error(`❌ Failed to process ${path.basename(filePath)}:`, error);
  }
}

async function testNeonConnection() {
  try {
    await prisma.$queryRaw`SELECT 1`;
    console.log('✅ Neon connection test successful');
    return true;
  } catch (error) {
    console.error('❌ Neon connection test failed:', error);
    return false;
  }
}

async function importToNeon() {
  try {
    console.log('🔍 Testing Neon connection...');
    const isConnected = await testNeonConnection();
    
    if (!isConnected) {
      throw new Error('Cannot proceed without Neon connection');
    }

    const exportDir = path.join(__dirname, '../../../exports');
    const tableFiles = fs.readdirSync(exportDir)
      .filter(f => f.endsWith('.sql'));

    console.log(`🔄 Importing ${tableFiles.length} tables...`);
    for (const file of tableFiles) {
      await importFile(path.join(exportDir, file));
    }

    const dbObjectsDir = path.join(exportDir, 'db_objects');
    if (fs.existsSync(dbObjectsDir)) {
      const objectFiles = ['functions.sql', 'procedures.sql', 'triggers.sql'];
      
      console.log('🔄 Importing database objects...');
      for (const file of objectFiles) {
        const filePath = path.join(dbObjectsDir, file);
        if (fs.existsSync(filePath)) {
          await importFile(filePath);
        }
      }
    }

    console.log('✅ Import completed successfully');
  } catch (error) {
    console.error('❌ Import failed:', error);
  } finally {
    await prisma.$disconnect();
  }
}

importToNeon();
