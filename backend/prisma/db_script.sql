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

