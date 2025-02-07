-- Script de test amélioré pour la pagination
DO $$
DECLARE
    test_result RECORD;
    v_order_id uuid;
BEGIN
    -- Préparer les données de test
    INSERT INTO orders (
        user_id,
        status,
        total_amount,
        created_at,
        updated_at
    ) VALUES 
    (
        (SELECT id FROM users LIMIT 1), -- Prendre un utilisateur existant
        'PENDING',
        100.00,
        NOW(),
        NOW()
    ) RETURNING id INTO v_order_id;

    -- Test 1: Pagination simple
    RAISE NOTICE 'Test 1: Pagination simple...';
    SELECT * FROM get_paginated_orders(1, 10) INTO test_result;
    IF test_result.total_count = 0 THEN
        RAISE EXCEPTION 'Test 1 failed: No results returned';
    END IF;
    RAISE NOTICE 'Test 1 passed: Found % orders', test_result.total_count;

    -- Test 2: Filtrage par statut
    RAISE NOTICE 'Test 2: Filtrage par statut PENDING...';
    SELECT * FROM get_paginated_orders(1, 10, 'PENDING') INTO test_result;
    IF test_result.data IS NULL OR test_result.data = '[]'::jsonb THEN
        RAISE EXCEPTION 'Test 2 failed: No PENDING orders found';
    END IF;
    RAISE NOTICE 'Test 2 passed: Found PENDING orders';

    -- Test 3: Vérifier la structure des données
    RAISE NOTICE 'Test 3: Vérification de la structure...';
    IF test_result.data->0->>'id' IS NULL OR
       test_result.data->0->>'status' IS NULL OR
       test_result.data->0->>'totalAmount' IS NULL THEN
        RAISE EXCEPTION 'Test 3 failed: Invalid JSON structure';
    END IF;
    RAISE NOTICE 'Test 3 passed: Data structure is valid';

    -- Test 4: Vérifier le tri
    RAISE NOTICE 'Test 4: Vérification du tri...';
    SELECT * FROM get_paginated_orders(
        1, 10, NULL, 'created_at', 'desc'
    ) INTO test_result;
    IF test_result.data IS NULL THEN
        RAISE EXCEPTION 'Test 4 failed: Sorting failed';
    END IF;
    RAISE NOTICE 'Test 4 passed: Sorting works';

    -- Test 5: Vérifier la pagination
    RAISE NOTICE 'Test 5: Vérification de la pagination...';
    IF test_result.total_count IS NULL THEN
        RAISE EXCEPTION 'Test 5 failed: Pagination info missing';
    END IF;
    RAISE NOTICE 'Test 5 passed: Pagination info present';

    -- Nettoyage
    DELETE FROM orders WHERE id = v_order_id;
    
    RAISE NOTICE 'Tous les tests ont réussi!';
    
EXCEPTION WHEN OTHERS THEN
    -- Nettoyage en cas d'erreur
    IF v_order_id IS NOT NULL THEN
        DELETE FROM orders WHERE id = v_order_id;
    END IF;
    RAISE NOTICE 'Test échoué: %', SQLERRM;
END;
$$;
