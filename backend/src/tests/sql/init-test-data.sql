-- Créer un article de test
INSERT INTO articles (id, name, description, base_price, premium_price, category_id)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'Article Test',
  'Article pour les tests',
  1000,
  1500,
  (SELECT id FROM article_categories LIMIT 1)
)
ON CONFLICT (id) DO NOTHING;

-- Créer un type de service de test
INSERT INTO service_types (id, name, description, is_default)
VALUES (
  '00000000-0000-0000-0000-000000000002',
  'Service Test',
  'Service pour les tests',
  true
)
ON CONFLICT (id) DO NOTHING;

-- Initialiser les variables de test
DO $$
BEGIN
  -- Stocker les IDs dans une table temporaire pour les tests
  CREATE TEMP TABLE IF NOT EXISTS test_variables (
    key TEXT PRIMARY KEY,
    value UUID
  );
  
  INSERT INTO test_variables (key, value)
  VALUES 
    ('test_article_id', '00000000-0000-0000-0000-000000000001'),
    ('test_service_type_id', '00000000-0000-0000-0000-000000000002')
  ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
END
$$;
