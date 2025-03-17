-- Cette requête liste toutes les fonctions et procédures du schéma public
SELECT
    p.proname as function_name,
    CASE
        WHEN p.prokind = 'f' THEN 'Function'
        WHEN p.prokind = 'p' THEN 'Procedure'
    END as type,
    pg_get_functiondef(p.oid) as source_code,
    COALESCE(d.description, '') as description
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
LEFT JOIN pg_description d ON p.oid = d.objoid
WHERE n.nspname = 'public'
AND p.proname NOT LIKE 'pg_%'
AND p.prokind IN ('f', 'p')
ORDER BY 
    p.prokind,
    p.proname;






-- Liste les triggers du schéma public

SELECT
    trigger_name,
    event_manipulation AS trigger_event,
    event_object_table AS table_name,
    action_statement AS trigger_definition,
    action_timing AS trigger_timing
FROM information_schema.triggers
WHERE trigger_schema = 'public'
ORDER BY trigger_name;





-- Liste les index du schéma public


SELECT 
    schemaname AS schema_name,
    tablename AS table_name,
    indexname AS index_name,
    indexdef AS index_definition
FROM pg_indexes
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY schemaname, tablename, indexname;







-- lister les different relation entre les tables du schéma public

SELECT
    tc.table_schema, 
    tc.table_name, 
    kcu.column_name,
    ccu.table_schema AS foreign_table_schema,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_schema = 'public';




-- __________________________________________________________________________________________________________________________________________________________________________________


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


-- __________________________________________________________________________________________________________________________________________________________________________________


-- requette pour verifier toutes les differente procedure et fonction liee a une table ou fesant reference a cette table 


SELECT p.proname AS procedure_name,
       pg_get_functiondef(p.oid) AS procedure_definition
FROM pg_proc p
WHERE p.prosrc LIKE '%weight_based_pricing%';





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




SELECT 
    t.tgname AS trigger_name,
    CASE 
        WHEN t.tgenabled = 'O' THEN 'ENABLED'
        ELSE 'DISABLED'
    END AS status,
    p.proname AS trigger_function,
    CASE 
        WHEN t.tgtype & 1 = 1 THEN 'ROW'
        ELSE 'STATEMENT'
    END AS trigger_level,
    CASE
        WHEN t.tgtype & 2 = 2 THEN 'BEFORE'
        WHEN t.tgtype & 64 = 64 THEN 'INSTEAD OF'
        ELSE 'AFTER'
    END AS timing,
    array_to_string(array(
        SELECT event::text
        FROM unnest(array[
            CASE WHEN t.tgtype & 4 = 4 THEN 'INSERT' END,
            CASE WHEN t.tgtype & 8 = 8 THEN 'DELETE' END,
            CASE WHEN t.tgtype & 16 = 16 THEN 'UPDATE' END
        ]) AS event
        WHERE event IS NOT NULL
    ), ', ') AS events
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE c.relname = 'articles'  -- Remplacez 'articles' par le nom de votre table
AND NOT t.tgisinternal;



-- Afficher toutes les valeurs de l'énumération status de la table orders
SELECT 
    t.typname as "Type Name",
    e.enumlabel as "Status Values"
FROM pg_type t 
JOIN pg_enum e ON t.oid = e.enumtypid  
WHERE t.typname = 'notifications'
ORDER BY e.enumsortorder;



-- Afficher les colonnes de la table d'une table donnée
SELECT column_name, data_type, character_maximum_length, column_default, is_nullable
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE table_name = 'offers';



-- afficher toutes les tables de la base de données

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_type = 'BASE TABLE'
ORDER BY table_name;


-- To list relationships for a specific table
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
    AND (tc.table_name = 'notifications' OR ccu.table_name = 'notifications')
ORDER BY source_table, source_column;



-- To list triggers for a specific table

SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement,
    action_timing
FROM information_schema.triggers
WHERE trigger_schema = 'public'
    AND event_object_table = 'notifications'
ORDER BY trigger_name;



-- requette pour verifier toutes les differente procedure et fonction liee a une table ou fesant reference a cette table 


SELECT p.proname AS procedure_name,
       pg_get_functiondef(p.oid) AS procedure_definition
FROM pg_proc p
WHERE p.prosrc LIKE '%notifications%';



-- Afficher les contraintes d'une tables
SELECT * FROM information_schema.table_constraints 
WHERE table_name = 'notifications';