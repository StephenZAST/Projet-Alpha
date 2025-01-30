[
  {
    "schema_name": "public",
    "function_name": "approve_withdrawal",
    "type": "Procedure",
    "source_code": "\nBEGIN\n    -- Vérifier et mettre à jour le statut\n    UPDATE commission_transactions\n    SET status = 'APPROVED',\n        updated_at = NOW()\n    WHERE id = p_withdrawal_id\n    AND type = 'WITHDRAWAL'\n    AND status = 'PENDING';\n\n    IF NOT FOUND THEN\n        RAISE EXCEPTION 'Withdrawal not found or not in pending status';\n    END IF;\nEND;\n"
  },
  {
    "schema_name": "public",
    "function_name": "archive_completed_orders",
    "type": "Function",
    "source_code": "\r\nBEGIN\r\n    IF NEW.status = 'DELIVERED' AND OLD.status != 'DELIVERED' THEN\r\n        INSERT INTO orders_archive \r\n        SELECT \r\n            OLD.*,\r\n            CURRENT_TIMESTAMP\r\n        FROM orders \r\n        WHERE id = OLD.id;\r\n    END IF;\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "schema_name": "public",
    "function_name": "calculate_available_commission",
    "type": "Function",
    "source_code": "\nDECLARE\n    v_total_commission DECIMAL;\nBEGIN\n    SELECT COALESCE(commission_balance, 0)\n    INTO v_total_commission\n    FROM affiliate_profiles\n    WHERE id = p_affiliate_id;\n\n    RETURN v_total_commission;\nEND;\n"
  },
  {
    "schema_name": "public",
    "function_name": "cleanup_old_orders",
    "type": "Function",
    "source_code": "\r\nDECLARE\r\n    archived_count INTEGER;\r\nBEGIN\r\n    -- Archive old completed orders\r\n    WITH orders_to_archive AS (\r\n        DELETE FROM orders \r\n        WHERE status = 'DELIVERED'\r\n        AND \"createdAt\" < NOW() - (days_threshold * INTERVAL '1 day')\r\n        RETURNING *\r\n    )\r\n    INSERT INTO orders_archive \r\n    SELECT \r\n        t.*,\r\n        NOW() as archived_at\r\n    FROM orders_to_archive t;\r\n\r\n    GET DIAGNOSTICS archived_count = ROW_COUNT;\r\n    RETURN archived_count;\r\nEND;\r\n"
  },
  {
    "schema_name": "public",
    "function_name": "create_order_with_items",
    "type": "Function",
    "source_code": "\r\nDECLARE\r\n    v_order_id UUID;\r\n    v_total_amount NUMERIC := 0;\r\n    v_item order_item_input;\r\n    v_article_price NUMERIC;\r\n    v_items_json JSON := '[]'::JSON;\r\nBEGIN\r\n    -- 1. Créer la commande\r\n    INSERT INTO orders (\r\n        \"userId\",\r\n        \"serviceId\",\r\n        \"addressId\",\r\n        \"isRecurring\",\r\n        \"recurrenceType\",\r\n        \"collectionDate\",\r\n        \"deliveryDate\",\r\n        \"affiliateCode\",\r\n        service_type_id,\r\n        \"paymentMethod\",\r\n        status,\r\n        \"totalAmount\",\r\n        \"createdAt\",\r\n        \"updatedAt\"\r\n    )\r\n    VALUES (\r\n        p_userId,\r\n        p_serviceId,\r\n        p_addressId,\r\n        p_isRecurring,\r\n        p_recurrenceType,\r\n        p_collectionDate,\r\n        p_deliveryDate,\r\n        p_affiliateCode,\r\n        p_service_type_id,\r\n        p_paymentMethod,\r\n        'PENDING',\r\n        0,\r\n        CURRENT_TIMESTAMP,\r\n        CURRENT_TIMESTAMP\r\n    )\r\n    RETURNING id INTO v_order_id;\r\n\r\n    -- 2. Créer les items et calculer le total\r\n    FOREACH v_item IN ARRAY p_items\r\n    LOOP\r\n        -- Récupérer le prix de l'article\r\n        SELECT \r\n            CASE \r\n                WHEN v_item.\"isPremium\" THEN \"premiumPrice\" \r\n                ELSE \"basePrice\" \r\n            END INTO v_article_price\r\n        FROM articles\r\n        WHERE id = v_item.\"articleId\";\r\n\r\n        -- Insérer l'item\r\n        INSERT INTO order_items (\r\n            \"orderId\",\r\n            \"articleId\",\r\n            \"serviceId\",\r\n            quantity,\r\n            \"unitPrice\",\r\n            \"createdAt\",\r\n            \"updatedAt\"\r\n        )\r\n        VALUES (\r\n            v_order_id,\r\n            v_item.\"articleId\",\r\n            p_serviceId,\r\n            v_item.quantity,\r\n            v_article_price,\r\n            CURRENT_TIMESTAMP,\r\n            CURRENT_TIMESTAMP\r\n        );\r\n\r\n        -- Ajouter à la somme totale\r\n        v_total_amount := v_total_amount + (v_article_price * v_item.quantity);\r\n\r\n        -- Construire le JSON des items\r\n        SELECT json_agg(row_to_json(i))\r\n        FROM (\r\n            SELECT i.*, \r\n                   a.name as article_name, \r\n                   a.description as article_description,\r\n                   ac.name as category_name\r\n            FROM order_items i\r\n            JOIN articles a ON i.\"articleId\" = a.id\r\n            LEFT JOIN article_categories ac ON a.\"categoryId\" = ac.id\r\n            WHERE i.\"orderId\" = v_order_id\r\n        ) i INTO v_items_json;\r\n    END LOOP;\r\n\r\n    -- 3. Mettre à jour le montant total de la commande\r\n    UPDATE orders\r\n    SET \"totalAmount\" = v_total_amount\r\n    WHERE id = v_order_id;\r\n\r\n    -- 4. Retourner le résultat\r\n    RETURN QUERY\r\n    SELECT \r\n        o.id,\r\n        o.\"userId\",\r\n        o.\"serviceId\",\r\n        o.\"addressId\",\r\n        o.\"totalAmount\",\r\n        o.status,\r\n        v_items_json::JSON as items\r\n    FROM orders o\r\n    WHERE o.id = v_order_id;\r\n\r\nEND;\r\n"
  },
  {
    "schema_name": "public",
    "function_name": "increment_referral_count",
    "type": "Function",
    "source_code": "\nDECLARE\n    v_new_count INTEGER;\nBEGIN\n    UPDATE affiliate_profiles\n    SET total_referrals = total_referrals + 1\n    WHERE id = p_affiliate_id\n    RETURNING total_referrals INTO v_new_count;\n\n    RETURN v_new_count;\nEND;\n"
  },
  {
    "schema_name": "public",
    "function_name": "initialize_user_loyalty_points",
    "type": "Function",
    "source_code": "\r\nBEGIN\r\n    INSERT INTO loyalty_points (user_id, \"pointsBalance\", \"totalEarned\")\r\n    VALUES (NEW.id, 0, 0);\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "schema_name": "public",
    "function_name": "maintain_orders_archive",
    "type": "Procedure",
    "source_code": "\r\nDECLARE\r\n    archived INTEGER;\r\nBEGIN\r\n    -- Archive orders older than 30 days\r\n    SELECT cleanup_old_orders(30) INTO archived;\r\n    \r\n    RAISE NOTICE 'Archived % old completed orders', archived;\r\nEND;\r\n"
  },
  {
    "schema_name": "public",
    "function_name": "process_withdrawal_request",
    "type": "Procedure",
    "source_code": "\nDECLARE\n    v_current_balance DECIMAL;\n    v_min_withdrawal DECIMAL := 25000; -- Montant minimum de retrait en FCFA\nBEGIN\n    -- Vérifier le statut de l'affilié\n    IF NOT EXISTS (\n        SELECT 1 FROM affiliate_profiles\n        WHERE id = p_affiliate_id\n        AND is_active = true\n        AND status = 'ACTIVE'\n    ) THEN\n        RAISE EXCEPTION 'Affiliate account is not active';\n    END IF;\n\n    -- Récupérer le solde actuel\n    SELECT commission_balance INTO v_current_balance\n    FROM affiliate_profiles\n    WHERE id = p_affiliate_id;\n\n    -- Vérifier le montant minimum\n    IF p_amount < v_min_withdrawal THEN\n        RAISE EXCEPTION 'Minimum withdrawal amount is % FCFA', v_min_withdrawal;\n    END IF;\n\n    -- Vérifier le solde disponible\n    IF v_current_balance < p_amount THEN\n        RAISE EXCEPTION 'Insufficient balance. Available: % FCFA', v_current_balance;\n    END IF;\n\n    -- Créer la transaction de retrait\n    INSERT INTO commission_transactions (\n        id,\n        affiliate_id,\n        amount,\n        type,\n        status,\n        created_at,\n        updated_at\n    ) VALUES (\n        gen_random_uuid(),\n        p_affiliate_id,\n        -p_amount,\n        'WITHDRAWAL',\n        'PENDING',\n        NOW(),\n        NOW()\n    );\n\n    -- Mettre à jour le solde de l'affilié\n    UPDATE affiliate_profiles\n    SET commission_balance = commission_balance - p_amount,\n        updated_at = NOW()\n    WHERE id = p_affiliate_id;\nEND;\n"
  },
  {
    "schema_name": "public",
    "function_name": "reject_withdrawal",
    "type": "Procedure",
    "source_code": "\nDECLARE\n    v_affiliate_id UUID;\n    v_amount DECIMAL;\nBEGIN\n    -- Récupérer les informations du retrait\n    SELECT affiliate_id, ABS(amount)\n    INTO v_affiliate_id, v_amount\n    FROM commission_transactions\n    WHERE id = p_withdrawal_id\n    AND type = 'WITHDRAWAL'\n    AND status = 'PENDING';\n\n    IF NOT FOUND THEN\n        RAISE EXCEPTION 'Withdrawal not found or not in pending status';\n    END IF;\n\n    -- Mettre à jour le statut de la transaction\n    UPDATE commission_transactions\n    SET status = 'REJECTED',\n        updated_at = NOW()\n    WHERE id = p_withdrawal_id;\n\n    -- Rembourser le montant sur le solde de l'affilié\n    UPDATE affiliate_profiles\n    SET commission_balance = commission_balance + v_amount,\n        updated_at = NOW()\n    WHERE id = v_affiliate_id;\nEND;\n"
  },
  {
    "schema_name": "public",
    "function_name": "reset_monthly_earnings",
    "type": "Procedure",
    "source_code": "\nBEGIN\n    UPDATE affiliate_profiles\n    SET monthly_earnings = 0\n    WHERE is_active = true;\nEND;\n"
  }
]