import { config } from 'dotenv';
import { createClient } from '@supabase/supabase-js';
import path from 'path';
import { before, after } from 'mocha'; // Ajout de l'import des fonctions Mocha

// Charge explicitement le fichier .env.test
config({ path: path.resolve(__dirname, '../../.env.test') });

// Vérifie l'environnement de test
if (process.env.NODE_ENV !== 'test') {
  throw new Error('Tests must be run in test environment!');
}

// Initialize test database client with test credentials
export const supabaseTest = createClient(
  process.env.SUPABASE_TEST_URL!,
  process.env.SUPABASE_TEST_KEY!,
  {
    db: {
      schema: 'test'
    }
  }
);

// Helper to clean test data
export async function cleanTestData() {
  const tables = [
    'service_types',
    'article_service_prices',
    'subscription_plans',
    'user_subscriptions',
    'weight_based_pricing'
  ];

  for (const table of tables) {
    await supabaseTest.from(table).delete().neq('id', '00000000-0000-0000-0000-000000000000');
  }
}

// Setup test environment
before(async () => {
  // Initialize test database
  await cleanTestData();
});

// Cleanup after tests
after(async () => {
  await cleanTestData();
});
