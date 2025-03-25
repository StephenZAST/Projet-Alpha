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

interface DBRelation {
  table_schema: string;
  table_name: string;
  column_name: string;
  foreign_table_schema: string;
  foreign_table_name: string;
  foreign_column_name: string;
  constraint_name?: string;
}

async function validateDatabaseRelations() {
  try {
    console.log('🔍 Starting database relations validation...');

    // 1. Get current relations from database
    const currentRelations = await getCurrentRelations();

    // 2. Read expected relations
    const relationsPath = path.join(__dirname, '../../prisma/db_functions/relations.json');
    if (!fs.existsSync(relationsPath)) {
      throw new Error('Relations definition file not found!');
    }

    const expectedRelations: DBRelation[] = JSON.parse(fs.readFileSync(relationsPath, 'utf8'));

    // 3. Compare and validate
    const validationResults = await validateRelations(expectedRelations, currentRelations);

    // 4. Generate report
    const report = generateValidationReport(validationResults, expectedRelations, currentRelations);

    // 5. Save report
    const reportPath = path.join(__dirname, '../../prisma/db_functions/validation_report.json');
    fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));

    console.log('✅ Validation completed');
    console.log(`📝 Report saved to: ${reportPath}`);

    return report;

  } catch (error) {
    console.error('❌ Validation failed:', error);
    throw error;
  } finally {
    await prisma.$disconnect();
  }
}

async function getCurrentRelations(): Promise<DBRelation[]> {
  const query = `
    SELECT
      kcu.table_schema,
      kcu.table_name,
      kcu.column_name,
      ccu.table_schema AS foreign_table_schema,
      ccu.table_name AS foreign_table_name,
      ccu.column_name AS foreign_column_name,
      kcu.constraint_name
    FROM information_schema.key_column_usage kcu
    JOIN information_schema.referential_constraints rc 
      ON kcu.constraint_name = rc.constraint_name
    JOIN information_schema.constraint_column_usage ccu 
      ON rc.unique_constraint_name = ccu.constraint_name
    WHERE kcu.table_schema = 'public';
  `;

  return await prisma.$queryRawUnsafe(query);
}

async function validateRelations(expected: DBRelation[], current: DBRelation[]) {
  const results = [];

  for (const expectedRel of expected) {
    const exists = current.some(currentRel => 
      currentRel.table_name === expectedRel.table_name &&
      currentRel.column_name === expectedRel.column_name &&
      currentRel.foreign_table_name === expectedRel.foreign_table_name &&
      currentRel.foreign_column_name === expectedRel.foreign_column_name
    );

    results.push({
      relation: `${expectedRel.table_name}.${expectedRel.column_name} -> ${expectedRel.foreign_table_name}.${expectedRel.foreign_column_name}`,
      status: exists ? 'valid' : 'missing',
      details: expectedRel
    });
  }

  return results;
}

function generateValidationReport(results: any[], expected: DBRelation[], current: DBRelation[]) {
  return {
    timestamp: new Date().toISOString(),
    summary: {
      expectedRelations: expected.length,
      currentRelations: current.length,
      validRelations: results.filter(r => r.status === 'valid').length,
      missingRelations: results.filter(r => r.status === 'missing').length
    },
    results: results,
    unexpectedRelations: current.filter(currentRel => 
      !expected.some(expectedRel =>
        currentRel.table_name === expectedRel.table_name &&
        currentRel.column_name === expectedRel.column_name &&
        currentRel.foreign_table_name === expectedRel.foreign_table_name &&
        currentRel.foreign_column_name === expectedRel.foreign_column_name
      )
    )
  };
}

export { validateDatabaseRelations };
