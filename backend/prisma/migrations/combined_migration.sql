-- Désactiver les contraintes de clé étrangère temporairement
SET session_replication_role = 'replica';

-- 1. Recréer la table order_items
\i 'backend/prisma/migrations/recreate_order_items.sql'

-- 2. Créer la procédure stockée
\i 'backend/prisma/migrations/create_order_procedure.sql'

-- Réactiver les contraintes de clé étrangère
SET session_replication_role = 'origin';

-- 3. Vérifier que tout est bien configuré
DO $$
BEGIN
    -- Vérifier que la table order_items existe
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'order_items') THEN
        RAISE EXCEPTION 'La table order_items n''existe pas';
    END IF;

    -- Vérifier que RLS est activé
    IF NOT EXISTS (
        SELECT 1
        FROM pg_tables
        WHERE tablename = 'order_items'
        AND rowsecurity = true
    ) THEN
        RAISE EXCEPTION 'RLS n''est pas activé pour order_items';
    END IF;

    -- Vérifier que les politiques existent
    IF NOT EXISTS (
        SELECT 1
        FROM pg_policies
        WHERE tablename = 'order_items'
    ) THEN
        RAISE EXCEPTION 'Aucune politique n''existe pour order_items';
    END IF;

    -- Vérifier que la procédure stockée existe
    IF NOT EXISTS (
        SELECT 1
        FROM pg_proc
        WHERE proname = 'create_order_with_items'
    ) THEN
        RAISE EXCEPTION 'La procédure create_order_with_items n''existe pas';
    END IF;

    RAISE NOTICE 'Toutes les vérifications ont réussi !';
END;
$$;

-- Afficher les politiques pour vérification
SELECT tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'order_items';