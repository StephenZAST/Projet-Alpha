[
  {
    "column_name": "id",
    "data_type": "uuid",
    "character_maximum_length": null,
    "column_default": "uuid_generate_v4()",
    "is_nullable": "NO"
  },
  {
    "column_name": "service_type_id",
    "data_type": "uuid",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "YES"
  },
  {
    "column_name": "min_weight",
    "data_type": "numeric",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "NO"
  },
  {
    "column_name": "max_weight",
    "data_type": "numeric",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "NO"
  },
  {
    "column_name": "price_per_kg",
    "data_type": "numeric",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "NO"
  },
  {
    "column_name": "is_active",
    "data_type": "boolean",
    "character_maximum_length": null,
    "column_default": "true",
    "is_nullable": "YES"
  },
  {
    "column_name": "created_at",
    "data_type": "timestamp with time zone",
    "character_maximum_length": null,
    "column_default": "CURRENT_TIMESTAMP",
    "is_nullable": "YES"
  },
  {
    "column_name": "updated_at",
    "data_type": "timestamp with time zone",
    "character_maximum_length": null,
    "column_default": "CURRENT_TIMESTAMP",
    "is_nullable": "YES"
  }
]


Triggers 

[
  {
    "trigger_name": "update_weight_based_pricing_timestamp",
    "event_manipulation": "UPDATE",
    "event_object_table": "weight_based_pricing",
    "action_statement": "EXECUTE FUNCTION update_timestamp_column()",
    "action_timing": "BEFORE"
  }
]





function 


[
  {
    "procedure_name": "calculate_weight_price",
    "procedure_definition": "CREATE OR REPLACE FUNCTION public.calculate_weight_price(p_service_id uuid, p_weight numeric)\n RETURNS numeric\n LANGUAGE plpgsql\nAS $function$\r\nDECLARE\r\n    v_price DECIMAL;\r\nBEGIN\r\n    -- Log des paramètres pour le débogage\r\n    RAISE NOTICE 'Calculating price for service_id: % and weight: %', p_service_id, p_weight;\r\n\r\n    SELECT price_per_kg * p_weight INTO v_price\r\n    FROM weight_based_pricing\r\n    WHERE service_id = p_service_id\r\n    AND p_weight BETWEEN min_weight AND max_weight;\r\n\r\n    IF v_price IS NULL THEN\r\n        RAISE EXCEPTION 'No pricing found for service_id: % and weight: %', p_service_id, p_weight;\r\n    END IF;\r\n\r\n    RETURN v_price;\r\nEND;\r\n$function$\n"
  },
  {
    "procedure_name": "initialize_default_pricing",
    "procedure_definition": "CREATE OR REPLACE FUNCTION public.initialize_default_pricing(p_service_id uuid, p_base_price numeric DEFAULT 100)\n RETURNS void\n LANGUAGE plpgsql\nAS $function$\r\nBEGIN\r\n    -- Supprimer les anciennes configurations si elles existent\r\n    DELETE FROM weight_based_pricing WHERE service_id = p_service_id;\r\n    \r\n    -- Insérer les nouvelles configurations par tranches de poids\r\n    INSERT INTO weight_based_pricing \r\n        (service_id, min_weight, max_weight, price_per_kg, created_at, updated_at)\r\n    VALUES\r\n        (p_service_id, 0, 5, p_base_price, NOW(), NOW()),\r\n        (p_service_id, 5.1, 10, p_base_price * 0.95, NOW(), NOW()),\r\n        (p_service_id, 10.1, 20, p_base_price * 0.90, NOW(), NOW()),\r\n        (p_service_id, 20.1, 999999, p_base_price * 0.85, NOW(), NOW());\r\nEND;\r\n$function$\n"
  }
]




_______________



[
  {
    "column_name": "id",
    "data_type": "uuid",
    "character_maximum_length": null,
    "column_default": "uuid_generate_v4()",
    "is_nullable": "NO"
  },
  {
    "column_name": "article_id",
    "data_type": "uuid",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "YES"
  },
  {
    "column_name": "service_type_id",
    "data_type": "uuid",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "YES"
  },
  {
    "column_name": "base_price",
    "data_type": "numeric",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "NO"
  },
  {
    "column_name": "premium_price",
    "data_type": "numeric",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "YES"
  },
  {
    "column_name": "is_available",
    "data_type": "boolean",
    "character_maximum_length": null,
    "column_default": "true",
    "is_nullable": "YES"
  },
  {
    "column_name": "price_per_kg",
    "data_type": "numeric",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "YES"
  },
  {
    "column_name": "created_at",
    "data_type": "timestamp with time zone",
    "character_maximum_length": null,
    "column_default": "CURRENT_TIMESTAMP",
    "is_nullable": "YES"
  },
  {
    "column_name": "updated_at",
    "data_type": "timestamp with time zone",
    "character_maximum_length": null,
    "column_default": "CURRENT_TIMESTAMP",
    "is_nullable": "YES"
  }
]




function / procedure


[
  {
    "procedure_name": "create_order_with_items",
    "procedure_definition": "CREATE OR REPLACE FUNCTION public.create_order_with_items(p_order_data jsonb, p_items jsonb[])\n RETURNS jsonb\n LANGUAGE plpgsql\nAS $function$\r\nDECLARE\r\n    v_order_id UUID;\r\n    v_total DECIMAL := 0;\r\n    v_item JSONB;\r\n    v_price DECIMAL;\r\n    v_service_price DECIMAL;\r\n    v_article_service_price article_service_prices%ROWTYPE;\r\nBEGIN\r\n    -- 1. Créer la commande\r\n    INSERT INTO orders (\r\n        \"userId\",\r\n        \"serviceId\",\r\n        \"addressId\",\r\n        \"service_type_id\",\r\n        \"isRecurring\",\r\n        \"recurrenceType\",\r\n        \"collectionDate\",\r\n        \"deliveryDate\",\r\n        \"affiliateCode\",\r\n        \"paymentMethod\",\r\n        status,\r\n        \"totalAmount\",\r\n        \"createdAt\",\r\n        \"updatedAt\"\r\n    )\r\n    VALUES (\r\n        (p_order_data->>'userId')::uuid,\r\n        (p_order_data->>'serviceId')::uuid,\r\n        (p_order_data->>'addressId')::uuid,\r\n        (p_order_data->>'serviceTypeId')::uuid,\r\n        (p_order_data->>'isRecurring')::boolean,\r\n        (p_order_data->>'recurrenceType')::recurrence_type,\r\n        (p_order_data->>'collectionDate')::timestamptz,\r\n        (p_order_data->>'deliveryDate')::timestamptz,\r\n        p_order_data->>'affiliateCode',\r\n        (p_order_data->>'paymentMethod')::payment_method_enum,\r\n        'PENDING'::order_status,\r\n        0,\r\n        CURRENT_TIMESTAMP,\r\n        CURRENT_TIMESTAMP\r\n    )\r\n    RETURNING id INTO v_order_id;\r\n\r\n    -- 2. Insérer les items avec gestion des prix\r\n    FOREACH v_item IN ARRAY p_items\r\n    LOOP\r\n        -- Récupérer le prix depuis article_service_prices\r\n        SELECT *\r\n        INTO v_article_service_price\r\n        FROM article_service_prices\r\n        WHERE article_id = (v_item->>'articleId')::uuid\r\n        AND service_type_id = (p_order_data->>'serviceTypeId')::uuid;\r\n\r\n        -- Calculer le prix en fonction du type (basic/premium)\r\n        v_price := CASE \r\n            WHEN (v_item->>'isPremium')::boolean AND v_article_service_price.premium_price IS NOT NULL \r\n                THEN v_article_service_price.premium_price\r\n            ELSE v_article_service_price.base_price\r\n        END;\r\n\r\n        -- Vérifier si le prix au kilo est applicable\r\n        IF (v_item->>'weight')::decimal IS NOT NULL AND v_article_service_price.price_per_kg IS NOT NULL THEN\r\n            v_price := v_article_service_price.price_per_kg * (v_item->>'weight')::decimal;\r\n        END IF;\r\n\r\n        -- Insérer l'item de commande\r\n        INSERT INTO order_items (\r\n            \"orderId\",\r\n            \"articleId\",\r\n            \"serviceId\",\r\n            quantity,\r\n            \"unitPrice\",\r\n            \"isPremium\",\r\n            weight_kg,\r\n            \"createdAt\",\r\n            \"updatedAt\"\r\n        )\r\n        VALUES (\r\n            v_order_id,\r\n            (v_item->>'articleId')::uuid,\r\n            (p_order_data->>'serviceId')::uuid,\r\n            (v_item->>'quantity')::integer,\r\n            v_price,\r\n            (v_item->>'isPremium')::boolean,\r\n            (v_item->>'weight')::decimal,\r\n            CURRENT_TIMESTAMP,\r\n            CURRENT_TIMESTAMP\r\n        );\r\n\r\n        -- Calculer le total\r\n        v_total := v_total + (v_price * (v_item->>'quantity')::integer);\r\n    END LOOP;\r\n\r\n    -- 3. Mettre à jour le total de la commande\r\n    UPDATE orders \r\n    SET \"totalAmount\" = v_total,\r\n        \"updatedAt\" = CURRENT_TIMESTAMP\r\n    WHERE id = v_order_id;\r\n\r\n    -- 4. Retourner le résultat avec les détails complets\r\n    RETURN (\r\n        SELECT jsonb_build_object(\r\n            'order', jsonb_build_object(\r\n                'id', o.id,\r\n                'userId', o.\"userId\",\r\n                'serviceId', o.\"serviceId\",\r\n                'addressId', o.\"addressId\",\r\n                'serviceTypeId', o.service_type_id,\r\n                'status', o.status,\r\n                'totalAmount', o.\"totalAmount\",\r\n                'createdAt', o.\"createdAt\",\r\n                'items', (\r\n                    SELECT jsonb_agg(jsonb_build_object(\r\n                        'id', oi.id,\r\n                        'articleId', oi.\"articleId\",\r\n                        'quantity', oi.quantity,\r\n                        'unitPrice', oi.\"unitPrice\",\r\n                        'isPremium', oi.\"isPremium\",\r\n                        'weightKg', oi.weight_kg,\r\n                        'total', oi.quantity * oi.\"unitPrice\"\r\n                    ))\r\n                    FROM order_items oi\r\n                    WHERE oi.\"orderId\" = o.id\r\n                )\r\n            )\r\n        )\r\n        FROM orders o\r\n        WHERE o.id = v_order_id\r\n    );\r\n\r\nEXCEPTION WHEN OTHERS THEN\r\n    -- Gestion des erreurs\r\n    RAISE EXCEPTION 'Erreur lors de la création de la commande: %', SQLERRM;\r\nEND;\r\n$function$\n"
  },
  {
    "procedure_name": "update_article_services",
    "procedure_definition": "CREATE OR REPLACE FUNCTION public.update_article_services(p_article_id uuid, p_service_updates json[])\n RETURNS SETOF article_service_prices\n LANGUAGE plpgsql\nAS $function$\r\nBEGIN\r\n    -- Mise à jour des prix des services\r\n    RETURN QUERY\r\n    WITH updates AS (\r\n        SELECT \r\n            (json->>'service_type_id')::UUID as service_type_id,\r\n            (json->>'base_price')::DECIMAL as base_price,\r\n            (json->>'premium_price')::DECIMAL as premium_price,\r\n            (json->>'price_per_kg')::DECIMAL as price_per_kg,\r\n            (json->>'is_available')::BOOLEAN as is_available\r\n        FROM json_array_elements(p_service_updates::JSON) as json\r\n    )\r\n    INSERT INTO article_service_prices (\r\n        article_id,\r\n        service_type_id,\r\n        base_price,\r\n        premium_price,\r\n        price_per_kg,\r\n        is_available\r\n    )\r\n    SELECT \r\n        p_article_id,\r\n        u.service_type_id,\r\n        u.base_price,\r\n        u.premium_price,\r\n        u.price_per_kg,\r\n        u.is_available\r\n    FROM updates u\r\n    ON CONFLICT (article_id, service_type_id)\r\n    DO UPDATE SET\r\n        base_price = EXCLUDED.base_price,\r\n        premium_price = EXCLUDED.premium_price,\r\n        price_per_kg = EXCLUDED.price_per_kg,\r\n        is_available = EXCLUDED.is_available,\r\n        updated_at = CURRENT_TIMESTAMP\r\n    RETURNING *;\r\nEND;\r\n$function$\n"
  },
  {
    "procedure_name": "update_article_services",
    "procedure_definition": "CREATE OR REPLACE FUNCTION public.update_article_services(p_article_id uuid, p_service_updates jsonb[])\n RETURNS jsonb\n LANGUAGE plpgsql\nAS $function$\r\nDECLARE\r\n  v_result JSONB;\r\nBEGIN\r\n  -- Validate article exists\r\n  IF NOT EXISTS (SELECT 1 FROM articles WHERE id = p_article_id) THEN\r\n    RAISE EXCEPTION 'Article not found';\r\n  END IF;\r\n\r\n  -- Update or insert service prices\r\n  WITH updated_prices AS (\r\n    SELECT \r\n      (update_data->>'service_type_id')::UUID as service_type_id,\r\n      (update_data->>'base_price')::NUMERIC as base_price,\r\n      (update_data->>'premium_price')::NUMERIC as premium_price,\r\n      (update_data->>'price_per_kg')::NUMERIC as price_per_kg,\r\n      (update_data->>'is_available')::BOOLEAN as is_available\r\n    FROM jsonb_array_elements(p_service_updates::JSONB) AS update_data\r\n  )\r\n  INSERT INTO article_service_prices (\r\n    article_id,\r\n    service_type_id,\r\n    base_price,\r\n    premium_price,\r\n    price_per_kg,\r\n    is_available,\r\n    created_at,\r\n    updated_at\r\n  )\r\n  SELECT\r\n    p_article_id,\r\n    service_type_id,\r\n    base_price,\r\n    premium_price,\r\n    price_per_kg,\r\n    is_available,\r\n    NOW(),\r\n    NOW()\r\n  FROM updated_prices\r\n  ON CONFLICT (article_id, service_type_id) \r\n  DO UPDATE SET\r\n    base_price = EXCLUDED.base_price,\r\n    premium_price = EXCLUDED.premium_price,\r\n    price_per_kg = EXCLUDED.price_per_kg,\r\n    is_available = EXCLUDED.is_available,\r\n    updated_at = NOW();\r\n\r\n  -- Return updated data\r\n  SELECT jsonb_build_object(\r\n    'article_id', p_article_id,\r\n    'services', jsonb_agg(\r\n      jsonb_build_object(\r\n        'service_type_id', asp.service_type_id,\r\n        'base_price', asp.base_price,\r\n        'premium_price', asp.premium_price,\r\n        'price_per_kg', asp.price_per_kg,\r\n        'is_available', asp.is_available,\r\n        'updated_at', asp.updated_at\r\n      )\r\n    )\r\n  )\r\n  INTO v_result\r\n  FROM article_service_prices asp\r\n  WHERE asp.article_id = p_article_id;\r\n\r\n  RETURN v_result;\r\nEND;\r\n$function$\n"
  }
]







_____________


[
  {
    "trigger_name": "update_service_types_timestamp",
    "event_manipulation": "UPDATE",
    "event_object_table": "service_types",
    "action_statement": "EXECUTE FUNCTION update_timestamp_column()",
    "action_timing": "BEFORE"
  }
]



