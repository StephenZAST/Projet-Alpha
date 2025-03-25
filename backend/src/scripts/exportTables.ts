import { createClient } from '@supabase/supabase-js';
import * as fs from 'fs';
import * as path from 'path';
import dotenv from 'dotenv';

dotenv.config();

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_KEY!
);

const tables = [
  'active_articles',
  'addresses',
  'article_categories',
  'affiliate_levels',
  'article_archives',
  'blog_articles',
  'article_services',
  'blog_categories',
  'discount_rules',
  'notification_rules',
  'notifications',
  'offers',
  'order_items',
  'order_notes',
  'order_metadata',
  'point_transactions',
  'orders',
  'orders_archive',
  'price_history',
  'reset_codes',
  'service_types',
  'services',
  'temp_notifications',
  'v_article_services',
  'user_offers',
  'user_subscriptions',
  'users',
  'article_service_prices',
  'articles',
  'affiliate_profiles',
  'article_service_compatibility',
  'commissionTransactions',
  'loyalty_points',
  'notification_preferences',
  'offer_articles',
  'offer_subscriptions',
  'order_weights',
  'price_configurations',
  'reward_claims',
  'rewards',
  'service_specific_prices',
  'subscription_plans',
  'v_price_migration_check',
  'weight_based_pricing'
];

interface TableExport {
  tableName: string;
  structure: any;
  data: any[];
}

async function exportTable(tableName: string): Promise<TableExport | null> {
  try {
    console.log(`🔄 Exporting ${tableName}...`);
    
    // Get table structure
    const { data: columns, error: structureError } = await supabase
      .from(tableName)
      .select()
      .limit(0);
    
    if (structureError) throw structureError;

    // Get table data
    const { data, error } = await supabase
      .from(tableName)
      .select('*');
    
    if (error) throw error;

    return {
      tableName,
      structure: columns,
      data: data || []
    };
  } catch (error) {
    console.error(`❌ Error exporting ${tableName}:`, error);
    return null;
  }
}

function generateCreateTableSQL(tableData: TableExport): string {
  // This is a simplified version - adjust according to your needs
  const columns = Object.keys(tableData.structure[0] || {})
    .map(col => `"${col}" TEXT`)
    .join(',\n  ');

  return `CREATE TABLE IF NOT EXISTS "${tableData.tableName}" (\n  ${columns}\n);`;
}

function generateInsertSQL(tableData: TableExport): string {
  if (!tableData.data.length) return '';

  const columns = Object.keys(tableData.data[0]);
  const values = tableData.data.map(row => {
    const rowValues = columns.map(col => {
      const value = row[col];
      return typeof value === 'string' ? `'${value.replace(/'/g, "''")}'` : value;
    });
    return `(${rowValues.join(', ')})`;
  });

  return `INSERT INTO "${tableData.tableName}" (${columns.map(c => `"${c}"`).join(', ')})
VALUES\n${values.join(',\n')};`;
}

async function exportAll() {
  try {
    const exportDir = path.join(__dirname, '../../../exports');
    if (!fs.existsSync(exportDir)) {
      fs.mkdirSync(exportDir, { recursive: true });
    }

    console.log(`📋 Starting export of ${tables.length} tables...`);

    for (const table of tables) {
      const result = await exportTable(table);
      if (result) {
        console.log(`✅ Exported ${table}`);
        
        // Save as JSON
        fs.writeFileSync(
          path.join(exportDir, `${table}.json`),
          JSON.stringify(result, null, 2)
        );

        // Generate and save SQL
        const createTable = generateCreateTableSQL(result);
        const insertData = generateInsertSQL(result);
        
        fs.writeFileSync(
          path.join(exportDir, `${table}.sql`),
          `${createTable}\n\n${insertData}`
        );
      } else {
        console.log(`❌ Failed to export ${table}`);
      }
    }

    console.log('🎉 Export completed successfully');
  } catch (error) {
    console.error('❌ Export failed:', error);
  }
}

exportAll();
