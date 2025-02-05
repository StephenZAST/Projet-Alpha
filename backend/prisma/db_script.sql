-- Cette requête liste toutes les fonctions et procédures du schéma public
SELECT 
    p.proname as function_name,
    CASE 
        WHEN p.prokind = 'f' THEN 'Function'
        WHEN p.prokind = 'p' THEN 'Procedure'
        ELSE 'Other'
    END as type,
    p.prokind as kind,  -- Ajouté pour permettre le tri
    pg_get_functiondef(p.oid) as source_code,
    COALESCE(d.description, '') as description
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
LEFT JOIN pg_description d ON p.oid = d.objoid
WHERE n.nspname = 'public'  -- Uniquement le schéma public
AND p.proname NOT LIKE 'pg_%'
AND p.prokind IN ('f', 'p')  -- Uniquement les fonctions et procédures
ORDER BY 
    kind,  -- Tri d'abord par type (p pour procédures, f pour fonctions)
    function_name;  -- Puis par nom de fonction

    SELECT 
    trigger_schema,
    trigger_name,
    event_manipulation AS trigger_event,
    event_object_schema AS table_schema,
    event_object_table AS table_name,
    action_statement AS trigger_definition,
    action_timing AS trigger_timing
FROM information_schema.triggers
WHERE trigger_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY trigger_schema, trigger_name;




-- Liste les index du schéma public


SELECT 
    schemaname AS schema_name,
    tablename AS table_name,
    indexname AS index_name,
    indexdef AS index_definition
FROM pg_indexes
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY schemaname, tablename, indexname;




-- Liste les triggers du schéma public




SELECT DISTINCT
    n.nspname as schema_name,
    p.proname as function_name,
    CASE 
        WHEN p.prokind = 'f' THEN 'Function'
        WHEN p.prokind = 'p' THEN 'Procedure'
        ELSE 'Other'
    END as type,
    p.prosrc as source_code
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname IN ('public', 'auth', 'storage')  -- Ajoutez ici vos schémas d'intérêt
AND p.proname NOT LIKE 'pg_%'
AND p.prokind IN ('f', 'p')  -- Uniquement les fonctions et procédures
ORDER BY schema_name, function_name;








-- Cette requête liste toutes les fonctions et procédures du schéma public





SELECT 
    n.nspname as schema_name,
    p.proname as function_name,
    CASE 
        WHEN p.prokind = 'f' THEN 'Function'
        WHEN p.prokind = 'p' THEN 'Procedure'
        ELSE 'Other'
    END as type,
    pg_get_functiondef(p.oid) as definition
FROM pg_proc p
LEFT JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
AND p.proname NOT LIKE 'pg_%'
ORDER BY schema_name, function_name;





-- lister les different schema disponible 




SELECT nspname FROM pg_namespace 
WHERE nspname NOT LIKE 'pg_%' 
AND nspname != 'information_schema';


-- List all tables first to verify
SELECT DISTINCT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Then list structure for each table without truncation
SELECT 
    c.table_schema,
    c.table_name,
    string_agg(
        c.column_name || ' ' || 
        c.data_type || 
        CASE 
            WHEN c.character_maximum_length IS NOT NULL 
            THEN '(' || c.character_maximum_length || ')'
            ELSE ''
        END || 
        CASE WHEN c.is_nullable = 'NO' THEN ' NOT NULL' ELSE '' END,
        E'\n'
    ) as columns
FROM information_schema.columns c
JOIN information_schema.tables t 
    ON c.table_name = t.table_name 
    AND c.table_schema = t.table_schema
WHERE t.table_schema = 'public'  
    AND t.table_type = 'BASE TABLE'
GROUP BY c.table_schema, c.table_name
ORDER BY c.table_name;

-- List foreign key relationships
SELECT
    tc.table_name AS source_table,
    kcu.column_name AS source_column,
    ccu.table_name AS target_table,
    ccu.column_name AS target_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_schema = 'public'
  AND tc.constraint_type = 'FOREIGN KEY'
ORDER BY source_table, source_column;





-- requette pour verifier toutes les differente procedure et fonction liee a une table ou fesant reference a cette table 


SELECT p.proname AS procedure_name,
       pg_get_functiondef(p.oid) AS procedure_definition
FROM pg_proc p
WHERE p.prosrc LIKE '%orders%';





-- all schema


[
  {
    "nspname": "auth"
  },
  {
    "nspname": "realtime"
  },
  {
    "nspname": "vault"
  },
  {
    "nspname": "graphql_public"
  },
  {
    "nspname": "graphql"
  },
  {
    "nspname": "public"
  },
  {
    "nspname": "extensions"
  },
  {
    "nspname": "storage"
  },
  {
    "nspname": "cron"
  }
]



-- Afficher toutes les valeurs de l'énumération status de la table orders
SELECT 
    t.typname as "Type Name",
    e.enumlabel as "Status Values"
FROM pg_type t 
JOIN pg_enum e ON t.oid = e.enumtypid  
WHERE t.typname = 'order_status'
ORDER BY e.enumsortorder;



-- Afficher les colonnes de la table d'une table donnée
SELECT column_name, data_type, character_maximum_length, column_default, is_nullable
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE table_name = 'orders';