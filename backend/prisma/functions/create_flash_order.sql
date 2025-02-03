CREATE OR REPLACE FUNCTION create_flash_order(
    order_data jsonb,
    note_text text
)
RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
    created_order jsonb;
    order_id uuid;
BEGIN
    -- 1. Insérer la commande
    INSERT INTO orders (
        "userId",
        "addressId",
        status,
        "totalAmount",
        "createdAt",
        "updatedAt"
    )
    VALUES (
        (order_data->>'userId')::uuid,
        (order_data->>'addressId')::uuid,
        (order_data->>'status')::text,
        COALESCE((order_data->>'totalAmount')::numeric, 0),
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    )
    RETURNING id INTO order_id;

    -- 2. Insérer la note si fournie
    IF note_text IS NOT NULL AND note_text != '' THEN
        INSERT INTO order_notes (order_id, note, created_at, updated_at)
        VALUES (order_id, note_text, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    END IF;

    -- 3. Récupérer la commande avec toutes ses relations
    WITH order_data AS (
        SELECT
            ord.*,
            json_build_object(
                'firstName', u.first_name,
                'lastName', u.last_name,
                'phone', u.phone
            ) as user,
            addr.* as address,
            (SELECT note FROM order_notes WHERE order_id = ord.id) as note
        FROM orders ord
        LEFT JOIN users u ON u.id = ord."userId"
        LEFT JOIN addresses addr ON addr.id = ord."addressId"
        WHERE ord.id = order_id
    )
    SELECT to_jsonb(order_data)
    INTO created_order
    FROM order_data;

    RETURN created_order;
END;
$$;

-- Ajout des droits d'exécution
GRANT EXECUTE ON FUNCTION create_flash_order TO service_role;

-- Commentaire sur la fonction
COMMENT ON FUNCTION create_flash_order IS 'Crée une commande flash avec sa note associée';