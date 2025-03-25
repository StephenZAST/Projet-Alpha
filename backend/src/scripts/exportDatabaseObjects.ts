import { createClient } from '@supabase/supabase-js';
import * as fs from 'fs';
import * as path from 'path';
import dotenv from 'dotenv';

dotenv.config();

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_KEY!
);

interface DatabaseObject {
  name: string;
  definition: string;
  type: 'function' | 'trigger' | 'procedure';
}

async function exportDatabaseObjects() {
  try {
    console.log('🔄 Exporting database objects...');
    const exportDir = path.join(__dirname, '../../../exports/db_objects');
    
    if (!fs.existsSync(exportDir)) {
      fs.mkdirSync(exportDir, { recursive: true });
    }

    // Export functions
    const { data: functions, error: funcError } = await supabase
      .rpc('list_functions');
    
    if (funcError) throw funcError;

    // Export triggers
    const { data: triggers, error: trigError } = await supabase
      .rpc('list_triggers');
    
    if (trigError) throw trigError;

    // Export procedures
    const { data: procedures, error: procError } = await supabase
      .rpc('list_procedures');
    
    if (procError) throw procError;

    // Save each object type
    fs.writeFileSync(
      path.join(exportDir, 'functions.sql'),
      functions?.map((f: any) => f.definition).join('\n\n') || ''
    );

    fs.writeFileSync(
      path.join(exportDir, 'triggers.sql'),
      triggers?.map((t: any) => t.definition).join('\n\n') || ''
    );

    fs.writeFileSync(
      path.join(exportDir, 'procedures.sql'),
      procedures?.map((p: any) => p.definition).join('\n\n') || ''
    );

    console.log('✅ Database objects exported successfully');
  } catch (error) {
    console.error('❌ Export failed:', error);
  }
}

exportDatabaseObjects();
