# Database Functions and Procedures Documentation

## Order Management Functions

### 1. create_order_with_items
| Property | Value |
|----------|--------|
| **Type** | Function |
| **Purpose** | Création d'une nouvelle commande avec ses articles |
| **Input Parameters** | - p_userId: UUID<br>- p_serviceId: UUID<br>- p_addressId: UUID<br>- p_items: order_item_input[]<br>- p_isRecurring: boolean<br>- p_recurrenceType: enum |
| **Returns** | Order avec items en JSON |
| **Key Actions** | - Crée la commande<br>- Ajoute les articles<br>- Calcule le total<br>- Gère les prix premium/standard |

### 2. cleanup_old_orders
| Property | Value |
|----------|--------|
| **Type** | Function |
| **Purpose** | Nettoyage et archivage des anciennes commandes |
| **Input Parameters** | - days_threshold: integer |
| **Returns** | Nombre de commandes archivées |
| **Key Actions** | - Archive les commandes livrées anciennes<br>- Met à jour orders_archive<br>- Supprime les anciennes entrées |

## Affiliate System Functions

### 1. process_withdrawal_request
| Property | Value |
|----------|--------|
| **Type** | Procedure |
| **Purpose** | Traitement des demandes de retrait d'affiliés |
| **Input Parameters** | - p_affiliate_id: UUID<br>- p_amount: decimal |
| **Validations** | - Minimum: 25000 FCFA<br>- Statut affilié actif<br>- Solde suffisant |
| **Key Actions** | - Vérifie l'éligibilité<br>- Crée transaction retrait<br>- Met à jour solde affilié |

### 2. approve_withdrawal
| Property | Value |
|----------|--------|
| **Type** | Procedure |
| **Purpose** | Approbation d'une demande de retrait |
| **Input Parameters** | - p_withdrawal_id: UUID |
| **Key Actions** | - Vérifie statut demande<br>- Met à jour en "APPROVED"<br>- Enregistre timestamp |

### 3. calculate_available_commission
| Property | Value |
|----------|--------|
| **Type** | Function |
| **Purpose** | Calcul commission disponible |
| **Input Parameters** | - p_affiliate_id: UUID |
| **Returns** | Montant total disponible (decimal) |
| **Key Actions** | - Récupère solde commission<br>- Applique calculs si nécessaire |

## User Management Functions

### 1. initialize_user_loyalty_points
| Property | Value |
|----------|--------|
| **Type** | Function |
| **Purpose** | Initialisation points fidélité nouveaux utilisateurs |
| **Triggered** | After INSERT on users |
| **Key Actions** | - Crée enregistrement points<br>- Initialise compteurs à 0 |

## Maintenance Procedures

### 1. maintain_orders_archive
| Property | Value |
|----------|--------|
| **Type** | Procedure |
| **Purpose** | Maintenance automatique des archives |
| **Scheduling** | Exécution périodique (30 jours) |
| **Key Actions** | - Nettoie anciennes commandes<br>- Maintient performance BD |

### 2. reset_monthly_earnings
| Property | Value |
|----------|--------|
| **Type** | Procedure |
| **Purpose** | Réinitialisation gains mensuels affiliés |
| **Scheduling** | Exécution mensuelle |
| **Key Actions** | - Remet à zéro gains mensuels<br>- Uniquement affiliés actifs |

## Code Source des Fonctions
[Note: Le code source complet de chaque fonction est disponible mais masqué pour la clarté.
Utilisez la commande \d+ nom_fonction pour voir le code source complet dans psql]


[
  {
    "function_name": "archive_article",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.archive_article(p_article_id uuid, p_reason text)\n RETURNS void\n LANGUAGE plpgsql\nAS $function$\r\nBEGIN\r\n  -- Copier l'article dans l'archive\r\n  INSERT INTO article_archives (\r\n    original_id, name, description, \"basePrice\", \"premiumPrice\", \r\n    \"categoryId\", \"createdAt\", \"updatedAt\", archived_reason\r\n  )\r\n  SELECT \r\n    id, name, description, \"basePrice\", \"premiumPrice\", \r\n    \"categoryId\", \"createdAt\", \"updatedAt\", p_reason\r\n  FROM articles \r\n  WHERE id = p_article_id;\r\n\r\n  -- Marquer l'article comme archivé\r\n  UPDATE articles \r\n  SET \"isDeleted\" = true, \r\n      \"deletedAt\" = CURRENT_TIMESTAMP\r\n  WHERE id = p_article_id;\r\nEND;\r\n$function$\n",
    "description": ""
  },
  {
    "function_name": "archive_completed_orders",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.archive_completed_orders()\n RETURNS trigger\n LANGUAGE plpgsql\nAS $function$\r\nBEGIN\r\n    IF NEW.status = 'DELIVERED' AND OLD.status != 'DELIVERED' THEN\r\n        INSERT INTO orders_archive \r\n        SELECT \r\n            OLD.*,\r\n            CURRENT_TIMESTAMP\r\n        FROM orders \r\n        WHERE id = OLD.id;\r\n    END IF;\r\n    RETURN NEW;\r\nEND;\r\n$function$\n",
    "description": ""
  },
  {
    "function_name": "calculate_available_commission",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.calculate_available_commission(p_affiliate_id uuid)\n RETURNS numeric\n LANGUAGE plpgsql\nAS $function$\r\nDECLARE\r\n    v_total_commission DECIMAL;\r\nBEGIN\r\n    SELECT COALESCE(commission_balance, 0)\r\n    INTO v_total_commission\r\n    FROM affiliate_profiles\r\n    WHERE id = p_affiliate_id;\r\n\r\n    RETURN v_total_commission;\r\nEND;\r\n$function$\n",
    "description": ""
  },
  {
    "function_name": "cleanup_old_orders",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.cleanup_old_orders(days_threshold integer DEFAULT 30)\n RETURNS integer\n LANGUAGE plpgsql\nAS $function$\r\nDECLARE\r\n    archived_count INTEGER;\r\nBEGIN\r\n    -- Archive old completed orders\r\n    WITH orders_to_archive AS (\r\n        DELETE FROM orders \r\n        WHERE status = 'DELIVERED'\r\n        AND \"createdAt\" < NOW() - (days_threshold * INTERVAL '1 day')\r\n        RETURNING *\r\n    )\r\n    INSERT INTO orders_archive \r\n    SELECT \r\n        t.*,\r\n        NOW() as archived_at\r\n    FROM orders_to_archive t;\r\n\r\n    GET DIAGNOSTICS archived_count = ROW_COUNT;\r\n    RETURN archived_count;\r\nEND;\r\n$function$\n",
    "description": ""
  },
  {
    "function_name": "complete_flash_order",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.complete_flash_order(p_order_id uuid, p_service_id uuid, p_items json[], p_collection_date timestamp without time zone DEFAULT NULL::timestamp without time zone, p_delivery_date timestamp without time zone DEFAULT NULL::timestamp without time zone)\n RETURNS json\n LANGUAGE plpgsql\nAS $function$\r\nDECLARE\r\n  v_order orders%ROWTYPE;\r\n  v_total DECIMAL := 0;\r\n  v_result JSON;\r\nBEGIN\r\n  -- 1. Récupérer et vérifier la commande\r\n  SELECT * INTO v_order\r\n  FROM orders \r\n  WHERE id = p_order_id AND status = 'DRAFT'\r\n  FOR UPDATE;\r\n\r\n  IF NOT FOUND THEN\r\n    RAISE EXCEPTION 'Commande flash non trouvée ou non modifiable';\r\n  END IF;\r\n\r\n  -- 2. Mettre à jour la commande\r\n  UPDATE orders SET\r\n    \"serviceId\" = p_service_id,\r\n    status = 'PENDING',\r\n    \"collectionDate\" = p_collection_date,\r\n    \"deliveryDate\" = p_delivery_date,\r\n    \"updatedAt\" = NOW()\r\n  WHERE id = p_order_id\r\n  RETURNING * INTO v_order;\r\n\r\n  -- 3. Insérer les articles et calculer le total\r\n  WITH inserted_items AS (\r\n    INSERT INTO order_items (\r\n      \"orderId\",\r\n      \"articleId\",\r\n      \"serviceId\",\r\n      quantity,\r\n      \"unitPrice\",\r\n      \"createdAt\",\r\n      \"updatedAt\"\r\n    )\r\n    SELECT \r\n      p_order_id,\r\n      (item->>'articleId')::UUID,\r\n      p_service_id,\r\n      (item->>'quantity')::INT,\r\n      (item->>'unitPrice')::DECIMAL,\r\n      NOW(),\r\n      NOW()\r\n    FROM json_array_elements(array_to_json(p_items)::JSON) AS item\r\n    RETURNING *\r\n  )\r\n  SELECT SUM(quantity * \"unitPrice\") INTO v_total FROM inserted_items;\r\n\r\n  -- 4. Mettre à jour le total\r\n  UPDATE orders \r\n  SET \"totalAmount\" = v_total\r\n  WHERE id = p_order_id;\r\n\r\n  -- 5. Construire le résultat JSON avec la structure exacte attendue\r\n  WITH order_details AS (\r\n    SELECT \r\n      o.*,\r\n      json_build_object(\r\n        'id', u.id,\r\n        'email', u.email,\r\n        'phone', u.phone,\r\n        'lastName', u.last_name,\r\n        'firstName', u.first_name\r\n      ) as user_info,\r\n      json_build_object(\r\n        'id', a.id,\r\n        'city', a.city,\r\n        'street', a.street,\r\n        'is_default', a.is_default,\r\n        'postal_code', a.postal_code,\r\n        'gps_latitude', a.gps_latitude,\r\n        'gps_longitude', a.gps_longitude\r\n      ) as address_info,\r\n      COALESCE(json_agg(\r\n        json_build_object(\r\n          'id', i.id,\r\n          'orderId', i.\"orderId\",\r\n          'articleId', i.\"articleId\",\r\n          'quantity', i.quantity,\r\n          'unitPrice', i.\"unitPrice\"\r\n        )\r\n      ) FILTER (WHERE i.id IS NOT NULL), '[]'::json) as items_info\r\n    FROM orders o\r\n    LEFT JOIN users u ON u.id = o.\"userId\"\r\n    LEFT JOIN addresses a ON a.id = o.\"addressId\"\r\n    LEFT JOIN order_items i ON i.\"orderId\" = o.id\r\n    WHERE o.id = p_order_id\r\n    GROUP BY o.id, u.id, a.id\r\n  )\r\n  SELECT json_build_object(\r\n    'data', json_build_object(\r\n      'order', json_build_object(\r\n        'id', od.id,\r\n        'status', od.status,\r\n        'userId', od.\"userId\",\r\n        'serviceId', od.\"serviceId\",\r\n        'addressId', od.\"addressId\",\r\n        'totalAmount', od.\"totalAmount\",\r\n        'createdAt', od.\"createdAt\",\r\n        'updatedAt', od.\"updatedAt\",\r\n        'user', od.user_info,\r\n        'address', od.address_info,\r\n        'items', od.items_info\r\n      )\r\n    )\r\n  ) INTO v_result\r\n  FROM order_details od;\r\n\r\n  RETURN v_result;\r\nEND;\r\n$function$\n",
    "description": ""
  },
  {
    "function_name": "create_flash_order",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.create_flash_order(order_data jsonb, note_text text DEFAULT NULL::text)\n RETURNS jsonb\n LANGUAGE plpgsql\nAS $function$\r\nDECLARE \r\n    created_order jsonb;\r\n    new_order_id uuid;\r\nBEGIN\r\n    -- 1. Insérer la commande avec le statut DRAFT\r\n    INSERT INTO orders (\r\n        \"userId\",\r\n        \"addressId\",\r\n        status,\r\n        \"totalAmount\",\r\n        \"createdAt\",\r\n        \"updatedAt\"\r\n    )\r\n    VALUES (\r\n        (order_data->>'userId')::uuid,\r\n        (order_data->>'addressId')::uuid,\r\n        'DRAFT'::order_status,\r\n        COALESCE((order_data->>'totalAmount')::numeric, 0),\r\n        CURRENT_TIMESTAMP,\r\n        CURRENT_TIMESTAMP\r\n    )\r\n    RETURNING id INTO new_order_id;\r\n\r\n    -- 2. Insérer la note seulement si elle contient du texte\r\n    IF note_text IS NOT NULL AND trim(note_text) != '' THEN\r\n        INSERT INTO order_notes (\r\n            order_id, \r\n            note, \r\n            created_at, \r\n            updated_at\r\n        )\r\n        VALUES (\r\n            new_order_id, \r\n            note_text, \r\n            CURRENT_TIMESTAMP, \r\n            CURRENT_TIMESTAMP\r\n        );\r\n    END IF;\r\n\r\n    -- 3. Récupérer la commande avec toutes ses relations\r\n    SELECT jsonb_build_object(\r\n        'id', o.id,\r\n        'userId', o.\"userId\",\r\n        'addressId', o.\"addressId\",\r\n        'status', o.status,\r\n        'totalAmount', o.\"totalAmount\",\r\n        'createdAt', o.\"createdAt\",\r\n        'updatedAt', o.\"updatedAt\",\r\n        'note', COALESCE(n.note, ''),\r\n        'address', CASE WHEN a.id IS NOT NULL THEN\r\n            jsonb_build_object(\r\n                'id', a.id,\r\n                'street', a.street,\r\n                'city', a.city,\r\n                'postal_code', a.postal_code,\r\n                'gps_latitude', a.gps_latitude,\r\n                'gps_longitude', a.gps_longitude,\r\n                'is_default', a.is_default\r\n            )\r\n        ELSE NULL END,\r\n        'user', CASE WHEN u.id IS NOT NULL THEN\r\n            jsonb_build_object(\r\n                'id', u.id,\r\n                'firstName', u.first_name,\r\n                'lastName', u.last_name,\r\n                'email', u.email,\r\n                'phone', u.phone\r\n            )\r\n        ELSE NULL END\r\n    ) INTO created_order\r\n    FROM orders o\r\n    LEFT JOIN (\r\n        SELECT on2.order_id, on2.note\r\n        FROM order_notes on2\r\n        WHERE on2.order_id = new_order_id\r\n    ) n ON true\r\n    LEFT JOIN addresses a ON a.id = o.\"addressId\"\r\n    LEFT JOIN users u ON u.id = o.\"userId\"\r\n    WHERE o.id = new_order_id;\r\n\r\n    RETURN created_order;\r\nEND;\r\n$function$\n",
    "description": "Crée une commande flash avec sa note associée"
  },
  {
    "function_name": "create_flash_order_with_metadata",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.create_flash_order_with_metadata(order_data jsonb, metadata jsonb, note_text text DEFAULT NULL::text)\n RETURNS jsonb\n LANGUAGE plpgsql\nAS $function$\r\nDECLARE\r\n    new_order_id uuid;\r\n    created_order jsonb;\r\nBEGIN\r\n    -- Debug log\r\n    RAISE NOTICE 'Creating flash order with note: %', note_text;\r\n\r\n    -- 1. Insérer la commande\r\n    INSERT INTO orders (\r\n        \"userId\",\r\n        \"addressId\",\r\n        status,\r\n        \"totalAmount\",\r\n        \"createdAt\",\r\n        \"updatedAt\"\r\n    ) VALUES (\r\n        (order_data->>'userId')::uuid,\r\n        (order_data->>'addressId')::uuid,\r\n        'DRAFT',\r\n        COALESCE((order_data->>'totalAmount')::numeric, 0),\r\n        NOW(),\r\n        NOW()\r\n    )\r\n    RETURNING id INTO new_order_id;\r\n\r\n    -- 2. Insérer les métadonnées\r\n    INSERT INTO order_metadata (\r\n        order_id,\r\n        is_flash_order,\r\n        metadata,\r\n        created_at,\r\n        updated_at\r\n    ) VALUES (\r\n        new_order_id,\r\n        true,\r\n        metadata,\r\n        NOW(),\r\n        NOW()\r\n    );\r\n\r\n    -- 3. Insérer la note si présente\r\n    IF note_text IS NOT NULL AND trim(note_text) != '' THEN\r\n        INSERT INTO order_notes (\r\n            order_id,\r\n            note,\r\n            created_at,\r\n            updated_at\r\n        ) VALUES (\r\n            new_order_id,\r\n            note_text,\r\n            NOW(),\r\n            NOW()\r\n        );\r\n    END IF;\r\n\r\n    -- 4. Retourner la commande avec toutes ses relations\r\n    WITH order_notes_data AS (\r\n        SELECT \r\n            on2.order_id,\r\n            on2.note\r\n        FROM order_notes on2\r\n        WHERE on2.order_id = new_order_id\r\n        LIMIT 1\r\n    )\r\n    SELECT jsonb_build_object(\r\n        'id', o.id,\r\n        'userId', o.\"userId\",\r\n        'addressId', o.\"addressId\",\r\n        'status', o.status,\r\n        'totalAmount', o.\"totalAmount\",\r\n        'createdAt', o.\"createdAt\",\r\n        'updatedAt', o.\"updatedAt\",\r\n        'note', COALESCE(n.note, note_text), -- Utiliser la note passée si aucune note trouvée\r\n        'metadata', jsonb_build_object(\r\n            'is_flash_order', m.is_flash_order,\r\n            'metadata', m.metadata\r\n        ),\r\n        'user', CASE WHEN u.id IS NOT NULL THEN\r\n            jsonb_build_object(\r\n                'id', u.id,\r\n                'email', u.email,\r\n                'phone', u.phone,\r\n                'firstName', u.first_name,\r\n                'lastName', u.last_name\r\n            )\r\n        END,\r\n        'address', CASE WHEN a.id IS NOT NULL THEN\r\n            jsonb_build_object(\r\n                'id', a.id,\r\n                'city', a.city,\r\n                'street', a.street,\r\n                'postal_code', a.postal_code,\r\n                'is_default', a.is_default\r\n            )\r\n        END\r\n    ) INTO created_order\r\n    FROM orders o \r\n    LEFT JOIN order_notes_data n ON n.order_id = o.id\r\n    LEFT JOIN order_metadata m ON m.order_id = o.id\r\n    LEFT JOIN users u ON u.id = o.\"userId\"\r\n    LEFT JOIN addresses a ON a.id = o.\"addressId\"\r\n    WHERE o.id = new_order_id;\r\n\r\n    RETURN created_order;\r\nEND;\r\n$function$\n",
    "description": ""
  },
  {
    "function_name": "create_order_with_items",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.create_order_with_items(p_userid uuid, p_serviceid uuid, p_addressid uuid, p_isrecurring boolean, p_recurrencetype recurrence_type, p_collectiondate timestamp with time zone, p_deliverydate timestamp with time zone, p_affiliatecode text, p_service_type_id uuid, p_paymentmethod payment_method_enum, p_items order_item_input[])\n RETURNS TABLE(id uuid, \"userId\" uuid, \"serviceId\" uuid, \"addressId\" uuid, \"totalAmount\" numeric, status order_status, items json)\n LANGUAGE plpgsql\nAS $function$\r\nDECLARE\r\n    v_order_id UUID;\r\n    v_total_amount NUMERIC := 0;\r\n    v_item order_item_input;\r\n    v_article_price NUMERIC;\r\n    v_items_json JSON := '[]'::JSON;\r\nBEGIN\r\n    -- 1. Créer la commande\r\n    INSERT INTO orders (\r\n        \"userId\",\r\n        \"serviceId\",\r\n        \"addressId\",\r\n        \"isRecurring\",\r\n        \"recurrenceType\",\r\n        \"collectionDate\",\r\n        \"deliveryDate\",\r\n        \"affiliateCode\",\r\n        service_type_id,\r\n        \"paymentMethod\",\r\n        status,\r\n        \"totalAmount\",\r\n        \"createdAt\",\r\n        \"updatedAt\"\r\n    )\r\n    VALUES (\r\n        p_userId,\r\n        p_serviceId,\r\n        p_addressId,\r\n        p_isRecurring,\r\n        p_recurrenceType,\r\n        p_collectionDate,\r\n        p_deliveryDate,\r\n        p_affiliateCode,\r\n        p_service_type_id,\r\n        p_paymentMethod,\r\n        'PENDING',\r\n        0,\r\n        CURRENT_TIMESTAMP,\r\n        CURRENT_TIMESTAMP\r\n    )\r\n    RETURNING id INTO v_order_id;\r\n\r\n    -- 2. Créer les items et calculer le total\r\n    FOREACH v_item IN ARRAY p_items\r\n    LOOP\r\n        -- Récupérer le prix de l'article\r\n        SELECT \r\n            CASE \r\n                WHEN v_item.\"isPremium\" THEN \"premiumPrice\" \r\n                ELSE \"basePrice\" \r\n            END INTO v_article_price\r\n        FROM articles\r\n        WHERE id = v_item.\"articleId\";\r\n\r\n        -- Insérer l'item\r\n        INSERT INTO order_items (\r\n            \"orderId\",\r\n            \"articleId\",\r\n            \"serviceId\",\r\n            quantity,\r\n            \"unitPrice\",\r\n            \"createdAt\",\r\n            \"updatedAt\"\r\n        )\r\n        VALUES (\r\n            v_order_id,\r\n            v_item.\"articleId\",\r\n            p_serviceId,\r\n            v_item.quantity,\r\n            v_article_price,\r\n            CURRENT_TIMESTAMP,\r\n            CURRENT_TIMESTAMP\r\n        );\r\n\r\n        -- Ajouter à la somme totale\r\n        v_total_amount := v_total_amount + (v_article_price * v_item.quantity);\r\n\r\n        -- Construire le JSON des items\r\n        SELECT json_agg(row_to_json(i))\r\n        FROM (\r\n            SELECT i.*, \r\n                   a.name as article_name, \r\n                   a.description as article_description,\r\n                   ac.name as category_name\r\n            FROM order_items i\r\n            JOIN articles a ON i.\"articleId\" = a.id\r\n            LEFT JOIN article_categories ac ON a.\"categoryId\" = ac.id\r\n            WHERE i.\"orderId\" = v_order_id\r\n        ) i INTO v_items_json;\r\n    END LOOP;\r\n\r\n    -- 3. Mettre à jour le montant total de la commande\r\n    UPDATE orders\r\n    SET \"totalAmount\" = v_total_amount\r\n    WHERE id = v_order_id;\r\n\r\n    -- 4. Retourner le résultat\r\n    RETURN QUERY\r\n    SELECT \r\n        o.id,\r\n        o.\"userId\",\r\n        o.\"serviceId\",\r\n        o.\"addressId\",\r\n        o.\"totalAmount\",\r\n        o.status,\r\n        v_items_json::JSON as items\r\n    FROM orders o\r\n    WHERE o.id = v_order_id;\r\n\r\nEND;\r\n$function$\n",
    "description": "Crée une commande et ses items de manière atomique, en calculant le prix total et en retournant la commande complète avec ses items"
  },
  {
    "function_name": "get_paginated_orders",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.get_paginated_orders(p_page integer, p_limit integer, p_status text DEFAULT NULL::text, p_sort_field text DEFAULT 'created_at'::text, p_sort_order text DEFAULT 'desc'::text)\n RETURNS TABLE(data jsonb, total_count bigint)\n LANGUAGE plpgsql\nAS $function$\r\nDECLARE\r\n  v_offset INTEGER;\r\n  v_where TEXT := 'TRUE';\r\n  v_order_by TEXT;\r\nBEGIN\r\n  -- Calculer l'offset\r\n  v_offset := (p_page - 1) * p_limit;\r\n  \r\n  -- Construire la clause WHERE pour le filtrage\r\n  IF p_status IS NOT NULL THEN\r\n    v_where := v_where || ' AND status = ' || quote_literal(p_status);\r\n  END IF;\r\n\r\n  -- Construire la clause ORDER BY sécurisée\r\n  v_order_by := CASE \r\n    WHEN p_sort_field IN ('created_at', 'updated_at', 'total_amount', 'status') THEN\r\n      format('o.%I %s', p_sort_field, \r\n        CASE WHEN upper(p_sort_order) = 'ASC' THEN 'ASC' ELSE 'DESC' END)\r\n    ELSE 'o.created_at DESC'\r\n  END;\r\n\r\n  RETURN QUERY EXECUTE format('\r\n    WITH total AS (\r\n      SELECT COUNT(*) AS count\r\n      FROM orders o\r\n      WHERE %s\r\n    ),\r\n    paginated_data AS (\r\n      SELECT \r\n        o.*,\r\n        jsonb_build_object(\r\n          ''id'', u.id,\r\n          ''firstName'', u.first_name,\r\n          ''lastName'', u.last_name,\r\n          ''email'', u.email,\r\n          ''phone'', u.phone\r\n        ) AS user,\r\n        jsonb_build_object(\r\n          ''id'', s.id,\r\n          ''name'', s.name,\r\n          ''price'', s.price\r\n        ) AS service,\r\n        jsonb_build_object(\r\n          ''id'', a.id,\r\n          ''street'', a.street,\r\n          ''city'', a.city,\r\n          ''postal_code'', a.postal_code,\r\n          ''gps_latitude'', a.gps_latitude,\r\n          ''gps_longitude'', a.gps_longitude\r\n        ) AS address,\r\n        jsonb_build_object(\r\n          ''note'', n.note\r\n        ) AS metadata,\r\n        (\r\n          SELECT jsonb_agg(jsonb_build_object(\r\n            ''id'', oi.id,\r\n            ''articleId'', oi.article_id,\r\n            ''quantity'', oi.quantity,\r\n            ''unitPrice'', oi.unit_price\r\n          ))\r\n          FROM order_items oi\r\n          WHERE oi.order_id = o.id\r\n        ) AS items\r\n      FROM orders o\r\n      LEFT JOIN users u ON o.user_id = u.id\r\n      LEFT JOIN services s ON o.service_id = s.id\r\n      LEFT JOIN addresses a ON o.address_id = a.id\r\n      LEFT JOIN order_notes n ON n.order_id = o.id\r\n      WHERE %s\r\n      ORDER BY %s\r\n      LIMIT %L OFFSET %L\r\n    )\r\n    SELECT \r\n      COALESCE(jsonb_agg(\r\n        jsonb_build_object(\r\n          ''id'', pd.id,\r\n          ''userId'', pd.user_id,\r\n          ''addressId'', pd.address_id,\r\n          ''serviceId'', pd.service_id,\r\n          ''status'', pd.status,\r\n          ''totalAmount'', pd.total_amount,\r\n          ''createdAt'', pd.created_at,\r\n          ''updatedAt'', pd.updated_at,\r\n          ''user'', pd.user,\r\n          ''service'', pd.service,\r\n          ''address'', pd.address,\r\n          ''metadata'', pd.metadata,\r\n          ''items'', pd.items\r\n        )\r\n      ), ''[]''::jsonb) AS data,\r\n      (SELECT count FROM total) AS total_count\r\n    FROM paginated_data pd',\r\n    v_where,\r\n    v_where,\r\n    v_order_by,\r\n    p_limit,\r\n    v_offset\r\n  );\r\nEND;\r\n$function$\n",
    "description": ""
  },
  {
    "function_name": "increment_referral_count",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.increment_referral_count(p_affiliate_id uuid)\n RETURNS integer\n LANGUAGE plpgsql\nAS $function$\r\nDECLARE\r\n    v_new_count INTEGER;\r\nBEGIN\r\n    UPDATE affiliate_profiles\r\n    SET total_referrals = total_referrals + 1\r\n    WHERE id = p_affiliate_id\r\n    RETURNING total_referrals INTO v_new_count;\r\n\r\n    RETURN v_new_count;\r\nEND;\r\n$function$\n",
    "description": ""
  },
  {
    "function_name": "initialize_user_loyalty_points",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.initialize_user_loyalty_points()\n RETURNS trigger\n LANGUAGE plpgsql\nAS $function$\r\nBEGIN\r\n    INSERT INTO loyalty_points (user_id, \"pointsBalance\", \"totalEarned\")\r\n    VALUES (NEW.id, 0, 0);\r\n    RETURN NEW;\r\nEND;\r\n$function$\n",
    "description": ""
  },
  {
    "function_name": "insert_flash_order_note",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.insert_flash_order_note()\n RETURNS trigger\n LANGUAGE plpgsql\nAS $function$\r\nBEGIN\r\n    -- Insertion de la note uniquement si c'est une commande flash (status = DRAFT)\r\n    IF NEW.status = 'DRAFT' AND TG_OP = 'INSERT' THEN\r\n        INSERT INTO order_notes (order_id, note)\r\n        VALUES (NEW.id, TG_ARGV[0]); -- La note sera passée comme argument du trigger\r\n    END IF;\r\n    RETURN NEW;\r\nEND;\r\n$function$\n",
    "description": ""
  },
  {
    "function_name": "reset_monthly_earnings",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.reset_monthly_earnings()\n RETURNS integer\n LANGUAGE plpgsql\n SECURITY DEFINER\nAS $function$\r\nDECLARE\r\n    v_count integer;\r\nBEGIN\r\n    UPDATE affiliate_profiles\r\n    SET \r\n        monthly_earnings = 0,\r\n        updated_at = NOW()\r\n    WHERE is_active = true\r\n    RETURNING COUNT(*) INTO v_count;\r\n\r\n    RETURN v_count;\r\nEND;\r\n$function$\n",
    "description": "Resets monthly earnings for all active affiliates and returns the number of affiliates updated"
  },
  {
    "function_name": "sync_order_note",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.sync_order_note()\n RETURNS trigger\n LANGUAGE plpgsql\nAS $function$\r\nBEGIN\r\n    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN\r\n        -- Mettre à jour les métadonnées quand une note est modifiée\r\n        UPDATE order_metadata\r\n        SET metadata = jsonb_set(\r\n            metadata,\r\n            '{note}',\r\n            to_jsonb(NEW.note)\r\n        )\r\n        WHERE order_id = NEW.order_id;\r\n    END IF;\r\n    RETURN NEW;\r\nEND;\r\n$function$\n",
    "description": ""
  },
  {
    "function_name": "trigger_set_timestamp",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.trigger_set_timestamp()\n RETURNS trigger\n LANGUAGE plpgsql\nAS $function$\r\nBEGIN\r\n  NEW.updated_at = NOW();\r\n  RETURN NEW;\r\nEND;\r\n$function$\n",
    "description": ""
  },
  {
    "function_name": "trigger_update_affiliate_level",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.trigger_update_affiliate_level()\n RETURNS trigger\n LANGUAGE plpgsql\nAS $function$\r\nBEGIN\r\n    IF NEW.total_earned <> OLD.total_earned THEN\r\n        CALL update_affiliate_level(NEW.id);\r\n    END IF;\r\n    RETURN NEW;\r\nEND;\r\n$function$\n",
    "description": ""
  },
  {
    "function_name": "update_loyalty_points_updated_at",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.update_loyalty_points_updated_at()\n RETURNS trigger\n LANGUAGE plpgsql\nAS $function$\r\nBEGIN\r\n    NEW.\"updatedAt\" = CURRENT_TIMESTAMP;\r\n    RETURN NEW;\r\nEND;\r\n$function$\n",
    "description": ""
  },
  {
    "function_name": "update_order_items_updated_at",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.update_order_items_updated_at()\n RETURNS trigger\n LANGUAGE plpgsql\nAS $function$\r\nBEGIN\r\n    NEW.\"updatedAt\" = CURRENT_TIMESTAMP;\r\n    RETURN NEW;\r\nEND;\r\n$function$\n",
    "description": ""
  },
  {
    "function_name": "update_orders_timestamp",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.update_orders_timestamp()\n RETURNS trigger\n LANGUAGE plpgsql\nAS $function$\r\nBEGIN\r\n    NEW.\"updatedAt\" = CURRENT_TIMESTAMP;\r\n    RETURN NEW;\r\nEND;\r\n$function$\n",
    "description": ""
  },
  {
    "function_name": "update_timestamp",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.update_timestamp()\n RETURNS trigger\n LANGUAGE plpgsql\nAS $function$\r\nBEGIN\r\n    NEW.updated_at = CURRENT_TIMESTAMP;\r\n    RETURN NEW;\r\nEND;\r\n$function$\n",
    "description": ""
  },
  {
    "function_name": "update_timestamp_column",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.update_timestamp_column()\n RETURNS trigger\n LANGUAGE plpgsql\nAS $function$\r\nBEGIN\r\n    -- Gérer à la fois camelCase et snake_case\r\n    IF TG_ARGV[0] = 'camelCase' THEN\r\n        NEW.\"updatedAt\" = CURRENT_TIMESTAMP;\r\n    ELSE\r\n        NEW.updated_at = CURRENT_TIMESTAMP;\r\n    END IF;\r\n    RETURN NEW;\r\nEND;\r\n$function$\n",
    "description": ""
  },
  {
    "function_name": "update_updated_at_column",
    "type": "Function",
    "source_code": "CREATE OR REPLACE FUNCTION public.update_updated_at_column()\n RETURNS trigger\n LANGUAGE plpgsql\nAS $function$\r\nBEGIN\r\n    NEW.updated_at = CURRENT_TIMESTAMP;\r\n    RETURN NEW;\r\nEND;\r\n$function$\n",
    "description": ""
  },
  {
    "function_name": "approve_withdrawal",
    "type": "Procedure",
    "source_code": "CREATE OR REPLACE PROCEDURE public.approve_withdrawal(IN p_withdrawal_id uuid)\n LANGUAGE plpgsql\nAS $procedure$\r\nBEGIN\r\n    -- Vérifier et mettre à jour le statut\r\n    UPDATE commission_transactions\r\n    SET status = 'APPROVED',\r\n        updated_at = NOW()\r\n    WHERE id = p_withdrawal_id\r\n    AND type = 'WITHDRAWAL'\r\n    AND status = 'PENDING';\r\n\r\n    IF NOT FOUND THEN\r\n        RAISE EXCEPTION 'Withdrawal not found or not in pending status';\r\n    END IF;\r\nEND;\r\n$procedure$\n",
    "description": ""
  },
  {
    "function_name": "maintain_orders_archive",
    "type": "Procedure",
    "source_code": "CREATE OR REPLACE PROCEDURE public.maintain_orders_archive()\n LANGUAGE plpgsql\nAS $procedure$\r\nDECLARE\r\n    archived INTEGER;\r\nBEGIN\r\n    -- Archive orders older than 30 days\r\n    SELECT cleanup_old_orders(30) INTO archived;\r\n    \r\n    RAISE NOTICE 'Archived % old completed orders', archived;\r\nEND;\r\n$procedure$\n",
    "description": ""
  },
  {
    "function_name": "process_affiliate_commission",
    "type": "Procedure",
    "source_code": "CREATE OR REPLACE PROCEDURE public.process_affiliate_commission(IN p_order_id uuid, IN p_order_amount numeric, IN p_affiliate_code character varying)\n LANGUAGE plpgsql\nAS $procedure$\r\nDECLARE\r\n    v_affiliate_id UUID;\r\n    v_parent_id UUID;\r\n    v_commission_rate DECIMAL;\r\n    v_commission_amount DECIMAL;\r\n    v_level_id UUID;\r\n    v_current_date TIMESTAMPTZ;\r\nBEGIN\r\n    -- Récupérer la date courante\r\n    v_current_date := CURRENT_TIMESTAMP;\r\n\r\n    -- Récupérer l'affilié principal\r\n    SELECT id, parent_affiliate_id, commission_rate, level_id\r\n    INTO v_affiliate_id, v_parent_id, v_commission_rate, v_level_id\r\n    FROM affiliate_profiles\r\n    WHERE affiliate_code = p_affiliate_code AND is_active = true;\r\n\r\n    IF v_affiliate_id IS NULL THEN\r\n        RAISE EXCEPTION 'Affiliate not found or inactive';\r\n    END IF;\r\n\r\n    -- Calculer la commission principale\r\n    v_commission_amount := (p_order_amount * v_commission_rate / 100);\r\n\r\n    -- Insérer la transaction de commission principale\r\n    INSERT INTO commission_transactions (\r\n        id,\r\n        affiliate_id,\r\n        order_id,\r\n        amount,\r\n        status,\r\n        created_at\r\n    ) VALUES (\r\n        gen_random_uuid(),\r\n        v_affiliate_id,\r\n        p_order_id,\r\n        v_commission_amount,\r\n        'PENDING',\r\n        v_current_date\r\n    );\r\n\r\n    -- Mettre à jour les statistiques de l'affilié\r\n    UPDATE affiliate_profiles\r\n    SET \r\n        commission_balance = commission_balance + v_commission_amount,\r\n        total_earned = total_earned + v_commission_amount,\r\n        monthly_earnings = monthly_earnings + v_commission_amount,\r\n        updated_at = v_current_date\r\n    WHERE id = v_affiliate_id;\r\n\r\n    -- Traiter la commission du parent si existant\r\n    WHILE v_parent_id IS NOT NULL LOOP\r\n        -- Récupérer les infos du parent\r\n        SELECT id, parent_affiliate_id, commission_rate\r\n        INTO v_affiliate_id, v_parent_id, v_commission_rate\r\n        FROM affiliate_profiles\r\n        WHERE id = v_parent_id AND is_active = true;\r\n\r\n        IF v_affiliate_id IS NOT NULL THEN\r\n            -- Calculer la commission indirecte (10% de la commission principale)\r\n            v_commission_amount := (v_commission_amount * 0.10);\r\n\r\n            -- Insérer la transaction de commission indirecte\r\n            INSERT INTO commission_transactions (\r\n                id,\r\n                affiliate_id,\r\n                order_id,\r\n                amount,\r\n                status,\r\n                created_at\r\n            ) VALUES (\r\n                gen_random_uuid(),\r\n                v_affiliate_id,\r\n                p_order_id,\r\n                v_commission_amount,\r\n                'PENDING',\r\n                v_current_date\r\n            );\r\n\r\n            -- Mettre à jour les statistiques du parent\r\n            UPDATE affiliate_profiles\r\n            SET \r\n                commission_balance = commission_balance + v_commission_amount,\r\n                total_earned = total_earned + v_commission_amount,\r\n                monthly_earnings = monthly_earnings + v_commission_amount,\r\n                updated_at = v_current_date\r\n            WHERE id = v_affiliate_id;\r\n        END IF;\r\n    END LOOP;\r\nEND;\r\n$procedure$\n",
    "description": ""
  },
  {
    "function_name": "process_affiliate_commission",
    "type": "Procedure",
    "source_code": "CREATE OR REPLACE PROCEDURE public.process_affiliate_commission(IN p_order_id uuid, IN p_order_amount numeric, IN p_affiliate_code text)\n LANGUAGE plpgsql\nAS $procedure$\r\nDECLARE\r\n    v_affiliate_id UUID;\r\n    v_direct_commission DECIMAL;\r\n    v_indirect_commission DECIMAL;\r\n    v_parent_id UUID;\r\nBEGIN\r\n    -- Récupérer l'ID de l'affilié\r\n    SELECT id, parent_affiliate_id\r\n    INTO v_affiliate_id, v_parent_id\r\n    FROM affiliate_profiles\r\n    WHERE affiliate_code = p_affiliate_code AND is_active = true;\r\n\r\n    IF v_affiliate_id IS NULL THEN\r\n        RAISE EXCEPTION 'Affiliate not found or inactive';\r\n    END IF;\r\n\r\n    -- Calculer la commission directe en utilisant total_referrals\r\n    SELECT (p_order_amount * 0.4) * (\r\n        CASE\r\n            WHEN total_referrals >= 20 THEN 0.20 -- 20%\r\n            WHEN total_referrals >= 10 THEN 0.15 -- 15%\r\n            ELSE 0.10 -- 10%\r\n        END\r\n    )\r\n    INTO v_direct_commission\r\n    FROM affiliate_profiles\r\n    WHERE id = v_affiliate_id;\r\n\r\n    -- Créer la transaction de commission directe\r\n    INSERT INTO commissionTransactions (\r\n        id,\r\n        affiliate_id,\r\n        order_id,\r\n        amount,\r\n        type,\r\n        status,\r\n        created_at\r\n    ) VALUES (\r\n        gen_random_uuid(),\r\n        v_affiliate_id,\r\n        p_order_id,\r\n        v_direct_commission,\r\n        'COMMISSION',\r\n        'APPROVED',\r\n        NOW()\r\n    );\r\n\r\n    -- Mettre à jour le solde et les statistiques de l'affilié\r\n    UPDATE affiliate_profiles SET\r\n        commission_balance = commission_balance + v_direct_commission,\r\n        total_earned = total_earned + v_direct_commission,\r\n        monthly_earnings = monthly_earnings + v_direct_commission\r\n    WHERE id = v_affiliate_id;\r\n\r\n    -- Si l'affilié a un parent, traiter la commission indirecte\r\n    IF v_parent_id IS NOT NULL THEN\r\n        -- Calculer la commission indirecte (10% de la commission directe)\r\n        v_indirect_commission := v_direct_commission * 0.1;\r\n\r\n        -- Créer la transaction de commission indirecte\r\n        INSERT INTO commissionTransactions (\r\n            id,\r\n            affiliate_id,\r\n            order_id,\r\n            amount,\r\n            type,\r\n            status,\r\n            created_at\r\n        ) VALUES (\r\n            gen_random_uuid(),\r\n            v_parent_id,\r\n            p_order_id,\r\n            v_indirect_commission,\r\n            'INDIRECT_COMMISSION',\r\n            'APPROVED',\r\n            NOW()\r\n        );\r\n\r\n        -- Mettre à jour le solde et les statistiques du parent\r\n        UPDATE affiliate_profiles SET\r\n            commission_balance = commission_balance + v_indirect_commission,\r\n            total_earned = total_earned + v_indirect_commission,\r\n            monthly_earnings = monthly_earnings + v_indirect_commission\r\n        WHERE id = v_parent_id;\r\n    END IF;\r\n\r\n    -- Mettre à jour le niveau de l'affilié\r\n    CALL update_affiliate_level(v_affiliate_id);\r\nEND;\r\n$procedure$\n",
    "description": ""
  },
  {
    "function_name": "process_withdrawal_request",
    "type": "Procedure",
    "source_code": "CREATE OR REPLACE PROCEDURE public.process_withdrawal_request(IN p_affiliate_id uuid, IN p_amount numeric)\n LANGUAGE plpgsql\nAS $procedure$\r\nDECLARE\r\n    v_current_balance DECIMAL;\r\n    v_min_withdrawal DECIMAL := 25000; -- Montant minimum de retrait en FCFA\r\nBEGIN\r\n    -- Vérifier le statut de l'affilié\r\n    IF NOT EXISTS (\r\n        SELECT 1 FROM affiliate_profiles\r\n        WHERE id = p_affiliate_id\r\n        AND is_active = true\r\n        AND status = 'ACTIVE'\r\n    ) THEN\r\n        RAISE EXCEPTION 'Affiliate account is not active';\r\n    END IF;\r\n\r\n    -- Récupérer le solde actuel\r\n    SELECT commission_balance INTO v_current_balance\r\n    FROM affiliate_profiles\r\n    WHERE id = p_affiliate_id;\r\n\r\n    -- Vérifier le montant minimum\r\n    IF p_amount < v_min_withdrawal THEN\r\n        RAISE EXCEPTION 'Minimum withdrawal amount is % FCFA', v_min_withdrawal;\r\n    END IF;\r\n\r\n    -- Vérifier le solde disponible\r\n    IF v_current_balance < p_amount THEN\r\n        RAISE EXCEPTION 'Insufficient balance. Available: % FCFA', v_current_balance;\r\n    END IF;\r\n\r\n    -- Créer la transaction de retrait\r\n    INSERT INTO commission_transactions (\r\n        id,\r\n        affiliate_id,\r\n        amount,\r\n        type,\r\n        status,\r\n        created_at,\r\n        updated_at\r\n    ) VALUES (\r\n        gen_random_uuid(),\r\n        p_affiliate_id,\r\n        -p_amount,\r\n        'WITHDRAWAL',\r\n        'PENDING',\r\n        NOW(),\r\n        NOW()\r\n    );\r\n\r\n    -- Mettre à jour le solde de l'affilié\r\n    UPDATE affiliate_profiles\r\n    SET commission_balance = commission_balance - p_amount,\r\n        updated_at = NOW()\r\n    WHERE id = p_affiliate_id;\r\nEND;\r\n$procedure$\n",
    "description": ""
  },
  {
    "function_name": "reject_withdrawal",
    "type": "Procedure",
    "source_code": "CREATE OR REPLACE PROCEDURE public.reject_withdrawal(IN p_withdrawal_id uuid, IN p_reason text)\n LANGUAGE plpgsql\nAS $procedure$\r\nDECLARE\r\n    v_affiliate_id UUID;\r\n    v_amount DECIMAL;\r\nBEGIN\r\n    -- Récupérer les informations du retrait\r\n    SELECT affiliate_id, ABS(amount)\r\n    INTO v_affiliate_id, v_amount\r\n    FROM commission_transactions\r\n    WHERE id = p_withdrawal_id\r\n    AND type = 'WITHDRAWAL'\r\n    AND status = 'PENDING';\r\n\r\n    IF NOT FOUND THEN\r\n        RAISE EXCEPTION 'Withdrawal not found or not in pending status';\r\n    END IF;\r\n\r\n    -- Mettre à jour le statut de la transaction\r\n    UPDATE commission_transactions\r\n    SET status = 'REJECTED',\r\n        updated_at = NOW()\r\n    WHERE id = p_withdrawal_id;\r\n\r\n    -- Rembourser le montant sur le solde de l'affilié\r\n    UPDATE affiliate_profiles\r\n    SET commission_balance = commission_balance + v_amount,\r\n        updated_at = NOW()\r\n    WHERE id = v_affiliate_id;\r\nEND;\r\n$procedure$\n",
    "description": ""
  },
  {
    "function_name": "update_affiliate_level",
    "type": "Procedure",
    "source_code": "CREATE OR REPLACE PROCEDURE public.update_affiliate_level(IN p_affiliate_id uuid)\n LANGUAGE plpgsql\nAS $procedure$\r\nDECLARE\r\n    v_total_earned DECIMAL;\r\n    v_new_level_id UUID;\r\nBEGIN\r\n    -- Récupérer le total des gains\r\n    SELECT total_earned INTO v_total_earned\r\n    FROM affiliate_profiles\r\n    WHERE id = p_affiliate_id;\r\n\r\n    -- Trouver le niveau approprié\r\n    SELECT id INTO v_new_level_id\r\n    FROM affiliate_levels\r\n    WHERE \"minEarnings\" <= v_total_earned\r\n    ORDER BY \"minEarnings\" DESC\r\n    LIMIT 1;\r\n\r\n    -- Mettre à jour le niveau de l'affilié\r\n    IF v_new_level_id IS NOT NULL THEN\r\n        UPDATE affiliate_profiles SET\r\n            level_id = v_new_level_id\r\n        WHERE id = p_affiliate_id;\r\n    END IF;\r\nEND;\r\n$procedure$\n",
    "description": ""
  }
]