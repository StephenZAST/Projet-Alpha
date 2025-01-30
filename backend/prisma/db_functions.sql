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