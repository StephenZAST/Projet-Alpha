-- Type pour les items en entrée de la procédure
DROP TYPE IF EXISTS order_item_input CASCADE;
CREATE TYPE order_item_input AS (
    "articleId" UUID,
    quantity INTEGER,
    "isPremium" BOOLEAN
);

-- Fonction pour créer une commande et ses items de manière atomique
CREATE OR REPLACE FUNCTION create_order_with_items(
    p_userId UUID,
    p_serviceId UUID,
    p_addressId UUID,
    p_isRecurring BOOLEAN,
    p_recurrenceType recurrence_type,
    p_collectionDate TIMESTAMPTZ,
    p_deliveryDate TIMESTAMPTZ,
    p_affiliateCode TEXT,
    p_service_type_id UUID,
    p_paymentMethod payment_method_enum,
    p_items order_item_input[]
)
RETURNS TABLE (
    id UUID,
    "userId" UUID,
    "serviceId" UUID,
    "addressId" UUID,
    "totalAmount" NUMERIC,
    status order_status,
    items JSON
) AS $$
DECLARE
    v_order_id UUID;
    v_total_amount NUMERIC := 0;
    v_item order_item_input;
    v_article_price NUMERIC;
    v_items_json JSON := '[]'::JSON;
BEGIN
    -- 1. Créer la commande
    INSERT INTO orders (
        "userId",
        "serviceId",
        "addressId",
        "isRecurring",
        "recurrenceType",
        "collectionDate",
        "deliveryDate",
        "affiliateCode",
        service_type_id,
        "paymentMethod",
        status,
        "totalAmount",
        "createdAt",
        "updatedAt"
    )
    VALUES (
        p_userId,
        p_serviceId,
        p_addressId,
        p_isRecurring,
        p_recurrenceType,
        p_collectionDate,
        p_deliveryDate,
        p_affiliateCode,
        p_service_type_id,
        p_paymentMethod,
        'PENDING',
        0,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    )
    RETURNING id INTO v_order_id;

    -- 2. Créer les items et calculer le total
    FOREACH v_item IN ARRAY p_items
    LOOP
        -- Récupérer le prix de l'article
        SELECT 
            CASE 
                WHEN v_item."isPremium" THEN "premiumPrice" 
                ELSE "basePrice" 
            END INTO v_article_price
        FROM articles
        WHERE id = v_item."articleId";

        -- Insérer l'item
        INSERT INTO order_items (
            "orderId",
            "articleId",
            "serviceId",
            quantity,
            "unitPrice",
            "createdAt",
            "updatedAt"
        )
        VALUES (
            v_order_id,
            v_item."articleId",
            p_serviceId,
            v_item.quantity,
            v_article_price,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        );

        -- Ajouter à la somme totale
        v_total_amount := v_total_amount + (v_article_price * v_item.quantity);

        -- Construire le JSON des items
        SELECT json_agg(row_to_json(i))
        FROM (
            SELECT i.*, 
                   a.name as article_name, 
                   a.description as article_description,
                   ac.name as category_name
            FROM order_items i
            JOIN articles a ON i."articleId" = a.id
            LEFT JOIN article_categories ac ON a."categoryId" = ac.id
            WHERE i."orderId" = v_order_id
        ) i INTO v_items_json;
    END LOOP;

    -- 3. Mettre à jour le montant total de la commande
    UPDATE orders
    SET "totalAmount" = v_total_amount
    WHERE id = v_order_id;

    -- 4. Retourner le résultat
    RETURN QUERY
    SELECT 
        o.id,
        o."userId",
        o."serviceId",
        o."addressId",
        o."totalAmount",
        o.status,
        v_items_json::JSON as items
    FROM orders o
    WHERE o.id = v_order_id;

END;
$$ LANGUAGE plpgsql;

-- Commentaire sur la fonction
COMMENT ON FUNCTION create_order_with_items IS 'Crée une commande et ses items de manière atomique, en calculant le prix total et en retournant la commande complète avec ses items';

-- S'assurer que le type existe
DO $$ BEGIN
    CREATE TYPE order_status AS ENUM ('PENDING', 'COLLECTING', 'COLLECTED', 'PROCESSING', 'READY', 'DELIVERING', 'DELIVERED', 'CANCELLED');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- S'assurer que le type existe
DO $$ BEGIN
    CREATE TYPE recurrence_type AS ENUM ('NONE', 'WEEKLY', 'BIWEEKLY', 'MONTHLY');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- S'assurer que le type existe
DO $$ BEGIN
    CREATE TYPE payment_method_enum AS ENUM ('CASH', 'ORANGE_MONEY');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;