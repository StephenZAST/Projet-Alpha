import { createClient } from '@supabase/supabase-js';
import { PrismaClient } from '@prisma/client';
import * as fs from 'fs';
import * as path from 'path';
import dotenv from 'dotenv';

dotenv.config();

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_KEY!
);

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.NEON_DB_URL
    }
  }
});

interface TableStructure {
  table_name: string;
  columns: Column[];
}

interface Column {
  column_name: string;
  data_type: string;
  is_nullable: string;
  column_default: string | null;
  column_position: number;  // Cette propriété doit correspondre à ordinal_position
}

interface DatabaseColumn {
  column_name: string;
  data_type: string;
  is_nullable: string;
  column_default: string | null;
  ordinal_position: number;
}

async function getTableStructure(tableName: string): Promise<TableStructure | null> {
  try {
    const { data, error } = await supabase
      .rpc('get_table_structure', { 
        table_name: tableName 
      });
    
    if (error) {
      console.error('RPC Error:', error);
      
      // Fallback : récupération via information_schema
      const { data: fallbackData, error: fallbackError } = await supabase
        .from('information_schema.columns')
        .select('column_name,data_type,is_nullable,column_default,ordinal_position')
        .eq('table_schema', 'public')
        .eq('table_name', tableName)
        .order('ordinal_position');

      if (fallbackError) throw fallbackError;
      
      // Mapper ordinal_position vers column_position
      const mappedColumns = (fallbackData || []).map((col: DatabaseColumn) => ({
        ...col,
        column_position: col.ordinal_position
      }));
      
      return {
        table_name: tableName,
        columns: mappedColumns
      };
    }

    // Mapper les données RPC pour inclure column_position
    const mappedColumns = (data || []).map((col: DatabaseColumn) => ({
      ...col,
      column_position: col.ordinal_position || 0
    }));

    return {
      table_name: tableName,
      columns: mappedColumns
    };
  } catch (error) {
    console.error(`Failed to get structure for ${tableName}:`, error);
    return null;
  }
}

function mapDataType(columnType: string, defaultValue: string | null): string {
  // Map USER-DEFINED types to their corresponding ENUM types
  if (columnType.toUpperCase() === 'USER-DEFINED') {
    const enumMatches = defaultValue?.match(/::([\w_]+)/);
    if (enumMatches) {
      const enumType = enumMatches[1];
      // Ajout des nouveaux types ENUM
      const knownEnums = [
        'order_status', 'user_role', 'status',
        'point_source', 'point_transaction_type',
        'discount_type_enum'
      ];
      
      return knownEnums.includes(enumType) ? enumType : 'text';
    }
    return 'text';
  }
  return columnType;
}

async function recreateTable(structure: TableStructure) {
  try {
    // 1. Drop table if exists
    await prisma.$executeRawUnsafe(`DROP TABLE IF EXISTS "${structure.table_name}" CASCADE`);

    // 2. Create new table with proper type mapping
    const columns = structure.columns.map(col => {
      const mappedType = mapDataType(col.data_type, col.column_default);
      let def = `"${col.column_name}" ${mappedType}`;
      
      // Gérer les contraintes NOT NULL
      if (col.is_nullable === 'NO') def += ' NOT NULL';
      
      // Gérer les valeurs par défaut
      if (col.column_default) {
        let defaultValue = col.column_default;
        // Conserver les types ENUM dans les valeurs par défaut
        if (defaultValue.includes('::')) {
          defaultValue = defaultValue.replace(/::[\w_]+$/, '');
        }
        def += ` DEFAULT ${defaultValue}`;
      }
      
      return def;
    });

    const createSQL = `CREATE TABLE "${structure.table_name}" (
      ${columns.join(',\n      ')}
    )`;

    console.log(`📝 Creating table with SQL:\n${createSQL}`);
    await prisma.$executeRawUnsafe(createSQL);
    console.log(`✅ Table structure created successfully`);

  } catch (error: any) {
    console.error(`❌ Failed to create table ${structure.table_name}:`, {
      error: error.message,
      code: error.code,
      meta: error.meta
    });
    throw error;
  }
}

async function insertData(tableName: string, data: any[], columns: string[]) {
  const batchSize = 50;
  for (let i = 0; i < data.length; i += batchSize) {
    const batch = data.slice(i, i + batchSize);
    try {
      const insertSQL = `
        INSERT INTO "${tableName}" (${columns.map(c => `"${c}"`).join(', ')})
        VALUES ${batch.map(row => 
          `(${columns.map(c => {
            const value = row[c];
            if (value === null) return 'NULL';
            if (typeof value === 'object') return `'${JSON.stringify(value).replace(/'/g, "''")}'`;
            // Gérer les valeurs ENUM correctement
            if (typeof value === 'string' && value.includes('::')) {
              return `'${value.split('::')[0].replace(/'/g, "''")}'`;
            }
            return `'${String(value).replace(/'/g, "''")}'`;
          }).join(', ')})`
        ).join(',\n')};
      `;

      await prisma.$executeRawUnsafe(insertSQL);
      console.log(`✅ Imported batch ${Math.floor(i/batchSize) + 1}/${Math.ceil(data.length/batchSize)}`);
    } catch (error: any) {
      console.error(`❌ Failed to import batch for ${tableName}:`, {
        error: error.message,
        batchIndex: Math.floor(i/batchSize) + 1
      });
      throw error;
    }
  }
}

// Définir la liste des tables avec le bon typage
const failedTables: string[] = [
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

async function compareAndSync() {
  try {
    console.log('🔧 Starting synchronization...');
    
    for (const tableName of failedTables) {
      console.log(`\n🔍 Processing ${tableName}...`);
      
      try {
        // 1. Get table structure from Supabase
        const structure = await getTableStructure(tableName);
        if (!structure) {
          console.log(`⚠️ Skipping ${tableName} - no structure found`);
          continue;
        }

        // 2. Recreate table in Neon
        console.log(`📦 Recreating table structure...`);
        await recreateTable(structure);
        console.log(`✅ Table structure created successfully`);

        // 3. Copy data
        console.log(`📥 Copying data...`);
        const { data, error } = await supabase
          .from(tableName)
          .select('*');

        if (error) {
          console.error(`❌ Failed to fetch data:`, error);
          continue;
        }

        if (data && data.length > 0) {
          const batchSize = 50; // Reduced batch size for better stability
          for (let i = 0; i < data.length; i += batchSize) {
            const batch = data.slice(i, i + batchSize);
            const columns = Object.keys(batch[0]);
            
            try {
              const insertSQL = `
                INSERT INTO "${tableName}" (${columns.map(c => `"${c}"`).join(', ')})
                VALUES ${batch.map(row => 
                  `(${columns.map(c => 
                    row[c] === null ? 'NULL' : 
                    typeof row[c] === 'object' ? `'${JSON.stringify(row[c]).replace(/'/g, "''")}'` :
                    `'${String(row[c]).replace(/'/g, "''")}'`
                  ).join(', ')})`
                ).join(',\n')};
              `;

              await prisma.$executeRawUnsafe(insertSQL);
              console.log(`✅ Imported batch ${i/batchSize + 1}/${Math.ceil(data.length/batchSize)}`);
            } catch (error: any) {
              console.error(`❌ Failed to import batch for ${tableName}:`, {
                error: error.message,
                batchIndex: i/batchSize + 1
              });
            }
          }
          
          console.log(`✅ Imported ${data.length} rows into ${tableName}`);
        }
      } catch (error: any) {
        console.error(`❌ Failed to process ${tableName}:`, error.message);
        // Continue with next table instead of stopping completely
        continue;
      }
    }

    console.log('\n✅ Synchronization completed');
  } catch (error) {
    console.error('❌ Sync failed:', error);
  } finally {
    await prisma.$disconnect();
  }
}

compareAndSync();

// Add export at the end of the file
export { compareAndSync };
