CREATE OR REPLACE FUNCTION create_flash_order_with_metadata(
    order_data jsonb,
    metadata jsonb,
    note_text text DEFAULT NULL
) RETURNS jsonb
LANGUAGE plpgsql
AS $$
DECLARE
    new_order_id uuid;
    created_order jsonb;
BEGIN
    -- Debug log
    RAISE NOTICE 'Creating flash order with note: %', note_text;

    -- 1. Insérer la commande
    INSERT INTO orders (
        "userId",
        "addressId",
        status,
        "totalAmount",
        "createdAt",
        "updatedAt"
    ) VALUES (
        (order_data->>'userId')::uuid,
        (order_data->>'addressId')::uuid,
        'DRAFT',
        COALESCE((order_data->>'totalAmount')::numeric, 0),
        NOW(),
        NOW()
    )
    RETURNING id INTO new_order_id;

    -- 2. Insérer les métadonnées
    INSERT INTO order_metadata (
        order_id,
        is_flash_order,
        metadata,
        created_at,
        updated_at
    ) VALUES (
        new_order_id,
        true,
        metadata,
        NOW(),
        NOW()
    );

    -- 3. Insérer la note si présente
    IF note_text IS NOT NULL AND trim(note_text) != '' THEN
        INSERT INTO order_notes (
            order_id,
            note,
            created_at,
            updated_at
        ) VALUES (
            new_order_id,
            note_text,
            NOW(),
            NOW()
        );
    END IF;

    -- 4. Retourner la commande avec toutes ses relations
    WITH order_notes_data AS (
        SELECT 
            on2.order_id,
            on2.note
        FROM order_notes on2
        WHERE on2.order_id = new_order_id
        LIMIT 1
    )
    SELECT jsonb_build_object(
        'id', o.id,
        'userId', o."userId",
        'addressId', o."addressId",
        'status', o.status,
        'totalAmount', o."totalAmount",
        'createdAt', o."createdAt",
        'updatedAt', o."updatedAt",
        'note', COALESCE(n.note, note_text), -- Utiliser la note passée si aucune note trouvée
        'metadata', jsonb_build_object(
            'is_flash_order', m.is_flash_order,
            'metadata', m.metadata
        ),
        'user', CASE WHEN u.id IS NOT NULL THEN
            jsonb_build_object(
                'id', u.id,
                'email', u.email,
                'phone', u.phone,
                'firstName', u.first_name,
                'lastName', u.last_name
            )
        END,
        'address', CASE WHEN a.id IS NOT NULL THEN
            jsonb_build_object(
                'id', a.id,
                'city', a.city,
                'street', a.street,
                'postal_code', a.postal_code,
                'is_default', a.is_default
            )
        END
    ) INTO created_order
    FROM orders o 
    LEFT JOIN order_notes_data n ON n.order_id = o.id
    LEFT JOIN order_metadata m ON m.order_id = o.id
    LEFT JOIN users u ON u.id = o."userId"
    LEFT JOIN addresses a ON a.id = o."addressId"
    WHERE o.id = new_order_id;

    RETURN created_order;
END;
$$;
