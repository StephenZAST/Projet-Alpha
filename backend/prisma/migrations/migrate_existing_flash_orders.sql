-- Migration pour les commandes flash existantes
DO $$
BEGIN
    -- 1. Identifier les commandes flash existantes (basé sur certains critères)
    INSERT INTO order_metadata (order_id, is_flash_order, created_at, updated_at)
    SELECT 
        o.id,
        TRUE,
        o."createdAt",
        o."updatedAt"
    FROM orders o
    WHERE 
        -- Critères pour identifier les commandes flash existantes
        (o.status = 'DRAFT' OR o.status = 'PENDING')
        AND NOT EXISTS (
            SELECT 1 
            FROM order_metadata om 
            WHERE om.order_id = o.id
        )
        AND o."serviceId" IS NULL -- Un critère possible pour les commandes flash
        AND o."createdAt" >= (CURRENT_DATE - INTERVAL '30 days'); -- Limiter aux 30 derniers jours

    -- 2. Log le nombre de commandes migrées
    RAISE NOTICE 'Migrated % flash orders', (
        SELECT count(*) 
        FROM order_metadata 
        WHERE is_flash_order = TRUE
    );
END $$;
