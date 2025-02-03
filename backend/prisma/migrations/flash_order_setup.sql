-- 1. Création de la table pour les notes de commandes
CREATE TABLE order_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    note TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index pour les recherches rapides par order_id
CREATE INDEX idx_order_notes_order_id ON order_notes(order_id);

-- Commentaires
COMMENT ON TABLE order_notes IS 'Notes associées aux commandes flash';
COMMENT ON COLUMN order_notes.order_id IS 'ID de la commande associée';
COMMENT ON COLUMN order_notes.note IS 'Contenu de la note';

-- 2. Création de la fonction pour créer une commande flash
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
        user_id,
        address_id,
        status,
        total_amount,
        created_at,
        updated_at
    )
    VALUES (
        (order_data->>'userId')::uuid,
        (order_data->>'addressId')::uuid,
        (order_data->>'status')::text,
        (order_data->>'totalAmount')::numeric,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    )
    RETURNING id INTO order_id;

    -- 2. Insérer la note
    IF note_text IS NOT NULL AND note_text != '' THEN
        INSERT INTO order_notes (order_id, note)
        VALUES (order_id, note_text);
    END IF;

    -- 3. Récupérer la commande avec toutes ses relations
    SELECT json_build_object(
        'order', ord.*,
        'user', json_build_object(
            'first_name', u.first_name,
            'last_name', u.last_name,
            'phone', u.phone
        ),
        'address', addr.*,
        'note', (SELECT note FROM order_notes WHERE order_id = ord.id)
    )::jsonb
    INTO created_order
    FROM orders ord
    LEFT JOIN users u ON u.id = ord.user_id
    LEFT JOIN addresses addr ON addr.id = ord.address_id
    WHERE ord.id = order_id;

    RETURN created_order;
END;
$$;

-- Ajout des droits d'exécution
GRANT EXECUTE ON FUNCTION create_flash_order TO service_role;

-- Commentaire sur la fonction
COMMENT ON FUNCTION create_flash_order IS 'Crée une commande flash avec sa note associée';