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

// Liste des tables qui ont échoué
const failedTables = [
  'active_articles',
  'addresses',
  'affiliate_levels',
  'affiliate_profiles',
  'articles',
  'article_categories',
  'article_services',
  'article_service_prices',
  'blog_categories',
  'commissionTransactions',
  'loyalty_points',
  'notifications',
  'notification_preferences',
  'notification_rules',
  'offers',
  'offer_articles',
  'offer_subscriptions',
  'orders',
  'orders_archive',
  'order_items',
  'order_metadata',
  'order_notes',
  'point_transactions',
  'reset_codes',
  'services',
  'service_types',
  'temp_notifications',
  'users',
  'v_article_services',
  'v_price_migration_check'
];

interface TableData {
  tableName: string;
  structure: any[];
  data: Record<string, any>[];
}

interface BatchData {
  [key: string]: string | number | boolean | null | object;
}

function parseCreateTable(sql: string): { tableName: string; columns: string[] } {
  const match = sql.match(/CREATE TABLE.*?"(\w+)"\s*\(([\s\S]+?)\)/i);
  if (!match) throw new Error('Invalid CREATE TABLE syntax');
  
  const [, tableName, columnsDef] = match;
  const columns = columnsDef
    .split(',')
    .map(col => col.trim())
    .filter(Boolean);

  return { tableName, columns };
}

function cleanInsertData(sql: string): string {
  return sql
    .replace(/\\/g, '\\\\') // Escape backslashes
    .replace(/'/g, "''")    // Escape single quotes
    .replace(/\r?\n/g, ' ') // Remove newlines
    .replace(/\s+/g, ' ')   // Normalize spaces
    .trim();
}

function formatValue(value: any): string {
  if (value === null) return 'NULL';
  if (typeof value === 'string') return `'${value.replace(/'/g, "''")}'`;
  if (typeof value === 'object') return `'${JSON.stringify(value).replace(/'/g, "''")}'`;
  return value.toString();
}

async function fixAndImportTable(tableName: string) {
  try {
    const filePath = path.join(__dirname, '../../../exports', `${tableName}.sql`);
    if (!fs.existsSync(filePath)) {
      console.log(`⚠️ File not found for table: ${tableName}`);
      return;
    }

    console.log(`🔄 Importing ${tableName}...`);
    const sql = fs.readFileSync(filePath, 'utf8');
    
    // Charger aussi le JSON pour avoir les données structurées
    const jsonPath = path.join(__dirname, '../../../exports', `${tableName}.json`);
    const tableData: TableData = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
    
    try {
      // Drop existing table
      await prisma.$executeRawUnsafe(`DROP TABLE IF EXISTS "${tableName}" CASCADE`);
      
      // Create table with proper column types
      const createTableSQL = sql.split('\n\n')[0].trim();
      await prisma.$executeRawUnsafe(createTableSQL);
      console.log(`✅ Table ${tableName} created`);

      // Insert data in batches
      if (tableData.data && tableData.data.length > 0) {
        const batchSize = 100;
        const batches = Math.ceil(tableData.data.length / batchSize);
        
        for (let i = 0; i < batches; i++) {
          const batchData: BatchData[] = tableData.data.slice(i * batchSize, (i + 1) * batchSize);
          const columns = Object.keys(batchData[0]);
          
          const values = batchData.map((row: BatchData) => 
            `(${columns.map(col => formatValue(row[col])).join(', ')})`
          ).join(',\n');

          const insertSQL = `
            INSERT INTO "${tableName}" (${columns.map(c => `"${c}"`).join(', ')})
            VALUES ${values};
          `;

          await prisma.$executeRawUnsafe(insertSQL);
        }
        
        console.log(`✅ Imported ${tableData.data.length} rows into ${tableName}`);
      }
    } catch (error: any) {
      console.error(`❌ Error with ${tableName}:`, {
        message: error.message,
        code: error.code,
        meta: error.meta
      });
    }
  } catch (error: any) {
    console.error(`❌ Failed to process ${tableName}:`, error.message);
  }
}

async function importFailedTables() {
  try {
    console.log('🔍 Testing Neon connection...');
    await prisma.$queryRaw`SELECT 1`;
    
    console.log(`📋 Starting import of ${failedTables.length} failed tables...`);
    
    for (const table of failedTables) {
      await fixAndImportTable(table);
    }

    console.log('✅ Retry import completed');
  } catch (error) {
    console.error('❌ Import retry failed:', error);
  } finally {
    await prisma.$disconnect();
  }
}

importFailedTables();
