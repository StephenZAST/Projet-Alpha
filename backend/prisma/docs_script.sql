Ce script :

✅ Génère un JSON structuré
✅ Exclut les fonctions système
✅ Inclut uniquement vos fonctions personnalisées
✅ Organise par catégories
✅ Fournit les signatures et définitions


WITH custom_functions AS (
    SELECT 
        p.proname as name,
        pg_get_function_result(p.oid) as return_type,
        pg_get_function_arguments(p.oid) as arguments,
        pg_get_functiondef(p.oid) as definition,
        CASE 
            WHEN p.proname LIKE '%order%' THEN 'Gestion des Commandes'
            WHEN p.proname LIKE '%article%' THEN 'Gestion des Articles'
            WHEN p.proname LIKE '%loyalty%' THEN 'Gestion de la Fidélité'
            WHEN p.proname LIKE '%affiliate%' THEN 'Gestion des Affiliés'
            WHEN p.proname LIKE '%service%' THEN 'Gestion des Services'
            ELSE 'Autres Fonctions'
        END as category
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'public'
    AND p.proname NOT IN (
        'armor', 'dearmor', 'crypt', 'gen_salt', 'digest', 
        'encrypt', 'decrypt', 'hmac', 'gen_random_bytes',
        'pgp_sym_encrypt', 'pgp_sym_decrypt', 'pgp_pub_encrypt',
        'pgp_pub_decrypt', 'uuid_generate_v1', 'uuid_generate_v4'
    )
    AND p.proname NOT LIKE 'pg_%'
    AND p.proname NOT LIKE 'uuid_%'
)
SELECT 
    json_build_object(
        'name', name,
        'category', category,
        'signature', name || '(' || arguments || ') RETURNS ' || return_type,
        'description', CASE 
            WHEN name LIKE '%trigger%' THEN 'Fonction déclencheur'
            WHEN name LIKE '%update%' THEN 'Fonction de mise à jour'
            WHEN name LIKE '%calculate%' THEN 'Fonction de calcul'
            WHEN name LIKE '%initialize%' THEN 'Fonction d''initialisation'
            WHEN name LIKE '%create%' THEN 'Fonction de création'
            ELSE 'Fonction utilitaire'
        END,
        'definition', definition
    ) as function_doc
FROM custom_functions
ORDER BY category, name;



_________________________________________________________________________________________________________________________

📝 Documentation Finale des Triggers
Créons un script de documentation pour tous les triggers installés :


WITH trigger_documentation AS (
    SELECT 
        t.tgname as trigger_name,
        c.relname as table_name,
        p.proname as function_name,
        CASE 
            WHEN t.tgtype & 2 > 0 THEN 'BEFORE'
            WHEN t.tgtype & 16 > 0 THEN 'AFTER'
        END as timing,
        CASE 
            WHEN c.relname LIKE '%order%' THEN 'Gestion des Commandes'
            WHEN c.relname LIKE '%subscription%' THEN 'Gestion des Abonnements'
            WHEN c.relname LIKE '%offer%' THEN 'Gestion des Offres'
            WHEN c.relname LIKE '%service%' THEN 'Gestion des Services'
            WHEN c.relname LIKE '%article%' THEN 'Gestion des Articles'
            WHEN c.relname LIKE '%loyalty%' THEN 'Gestion de la Fidélité'
            ELSE 'Autres'
        END as category
    FROM pg_trigger t
    JOIN pg_class c ON t.tgrelid = c.oid
    JOIN pg_proc p ON t.tgfoid = p.oid
    WHERE c.relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
)
SELECT 
    json_build_object(
        'category', category,
        'triggers', json_agg(
            json_build_object(
                'name', trigger_name,
                'table', table_name,
                'function', function_name,
                'timing', timing
            ) ORDER BY trigger_name
        )
    ) as documentation
FROM trigger_documentation
GROUP BY category
ORDER BY category;




_________________________________________________________________________________________________________________________


Script pour Documenter les Relations de la Base de Données


WITH RECURSIVE fk_tree AS (
    SELECT 
        c.conname AS constraint_name,
        c.contype AS constraint_type,
        ns.nspname AS schema_name,
        cl.relname AS table_name,
        a.attname AS column_name,
        ref_ns.nspname AS ref_schema,
        ref_cl.relname AS ref_table,
        ref_a.attname AS ref_column,
        c.confdeltype AS delete_rule,
        c.confupdtype AS update_rule
    FROM pg_constraint c
    JOIN pg_namespace ns ON c.connamespace = ns.oid
    JOIN pg_class cl ON c.conrelid = cl.oid
    JOIN pg_attribute a ON a.attrelid = c.conrelid 
        AND a.attnum = ANY(c.conkey)
    LEFT JOIN pg_class ref_cl ON c.confrelid = ref_cl.oid
    LEFT JOIN pg_namespace ref_ns ON ref_cl.relnamespace = ref_ns.oid
    LEFT JOIN pg_attribute ref_a ON ref_a.attrelid = c.confrelid 
        AND ref_a.attnum = ANY(c.confkey)
    WHERE c.contype = 'f'
)
SELECT 
    table_name AS "Table",
    column_name AS "Colonne",
    constraint_name AS "Nom Contrainte",
    ref_table AS "Table Référencée",
    ref_column AS "Colonne Référencée",
    CASE 
        WHEN delete_rule = 'a' THEN 'NO ACTION'
        WHEN delete_rule = 'c' THEN 'CASCADE'
        WHEN delete_rule = 'r' THEN 'RESTRICT'
        WHEN delete_rule = 'n' THEN 'SET NULL'
        ELSE delete_rule::text
    END AS "Règle Suppression",
    CASE 
        WHEN update_rule = 'a' THEN 'NO ACTION'
        WHEN update_rule = 'c' THEN 'CASCADE'
        WHEN update_rule = 'r' THEN 'RESTRICT'
        WHEN update_rule = 'n' THEN 'SET NULL'
        ELSE update_rule::text
    END AS "Règle Mise à Jour"
FROM fk_tree
WHERE schema_name = 'public'
ORDER BY 
    table_name,
    column_name;