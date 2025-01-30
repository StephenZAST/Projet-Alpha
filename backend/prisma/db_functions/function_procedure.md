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
    "function_name": "process_affiliate_commission",
    "type": "Procedure",
    "source_code": "\nDECLARE\n    v_affiliate_id UUID;\n    v_direct_commission DECIMAL;\n    v_indirect_commission DECIMAL;\n    v_parent_id UUID;\nBEGIN\n    -- Récupérer l'ID de l'affilié\n    SELECT id, parent_affiliate_id\n    INTO v_affiliate_id, v_parent_id\n    FROM affiliate_profiles\n    WHERE affiliate_code = p_affiliate_code AND is_active = true;\n\n    IF v_affiliate_id IS NULL THEN\n        RAISE EXCEPTION 'Affiliate not found or inactive';\n    END IF;\n\n    -- Calculer la commission directe en utilisant total_referrals\n    SELECT (p_order_amount * 0.4) * (\n        CASE\n            WHEN total_referrals >= 20 THEN 0.20 -- 20%\n            WHEN total_referrals >= 10 THEN 0.15 -- 15%\n            ELSE 0.10 -- 10%\n        END\n    )\n    INTO v_direct_commission\n    FROM affiliate_profiles\n    WHERE id = v_affiliate_id;\n\n    -- Créer la transaction de commission directe\n    INSERT INTO commissionTransactions (\n        id,\n        affiliate_id,\n        order_id,\n        amount,\n        type,\n        status,\n        created_at\n    ) VALUES (\n        gen_random_uuid(),\n        v_affiliate_id,\n        p_order_id,\n        v_direct_commission,\n        'COMMISSION',\n        'APPROVED',\n        NOW()\n    );\n\n    -- Mettre à jour le solde et les statistiques de l'affilié\n    UPDATE affiliate_profiles SET\n        commission_balance = commission_balance + v_direct_commission,\n        total_earned = total_earned + v_direct_commission,\n        monthly_earnings = monthly_earnings + v_direct_commission\n    WHERE id = v_affiliate_id;\n\n    -- Si l'affilié a un parent, traiter la commission indirecte\n    IF v_parent_id IS NOT NULL THEN\n        -- Calculer la commission indirecte (10% de la commission directe)\n        v_indirect_commission := v_direct_commission * 0.1;\n\n        -- Créer la transaction de commission indirecte\n        INSERT INTO commissionTransactions (\n            id,\n            affiliate_id,\n            order_id,\n            amount,\n            type,\n            status,\n            created_at\n        ) VALUES (\n            gen_random_uuid(),\n            v_parent_id,\n            p_order_id,\n            v_indirect_commission,\n            'INDIRECT_COMMISSION',\n            'APPROVED',\n            NOW()\n        );\n\n        -- Mettre à jour le solde et les statistiques du parent\n        UPDATE affiliate_profiles SET\n            commission_balance = commission_balance + v_indirect_commission,\n            total_earned = total_earned + v_indirect_commission,\n            monthly_earnings = monthly_earnings + v_indirect_commission\n        WHERE id = v_parent_id;\n    END IF;\n\n    -- Mettre à jour le niveau de l'affilié\n    CALL update_affiliate_level(v_affiliate_id);\nEND;\n"
  },
  {
    "schema_name": "public",
    "function_name": "process_affiliate_commission",
    "type": "Procedure",
    "source_code": "\r\nDECLARE\r\n    v_affiliate_id UUID;\r\n    v_parent_id UUID;\r\n    v_commission_rate DECIMAL;\r\n    v_commission_amount DECIMAL;\r\n    v_level_id UUID;\r\n    v_current_date TIMESTAMPTZ;\r\nBEGIN\r\n    -- Récupérer la date courante\r\n    v_current_date := CURRENT_TIMESTAMP;\r\n\r\n    -- Récupérer l'affilié principal\r\n    SELECT id, parent_affiliate_id, commission_rate, level_id\r\n    INTO v_affiliate_id, v_parent_id, v_commission_rate, v_level_id\r\n    FROM affiliate_profiles\r\n    WHERE affiliate_code = p_affiliate_code AND is_active = true;\r\n\r\n    IF v_affiliate_id IS NULL THEN\r\n        RAISE EXCEPTION 'Affiliate not found or inactive';\r\n    END IF;\r\n\r\n    -- Calculer la commission principale\r\n    v_commission_amount := (p_order_amount * v_commission_rate / 100);\r\n\r\n    -- Insérer la transaction de commission principale\r\n    INSERT INTO commission_transactions (\r\n        id,\r\n        affiliate_id,\r\n        order_id,\r\n        amount,\r\n        status,\r\n        created_at\r\n    ) VALUES (\r\n        gen_random_uuid(),\r\n        v_affiliate_id,\r\n        p_order_id,\r\n        v_commission_amount,\r\n        'PENDING',\r\n        v_current_date\r\n    );\r\n\r\n    -- Mettre à jour les statistiques de l'affilié\r\n    UPDATE affiliate_profiles\r\n    SET \r\n        commission_balance = commission_balance + v_commission_amount,\r\n        total_earned = total_earned + v_commission_amount,\r\n        monthly_earnings = monthly_earnings + v_commission_amount,\r\n        updated_at = v_current_date\r\n    WHERE id = v_affiliate_id;\r\n\r\n    -- Traiter la commission du parent si existant\r\n    WHILE v_parent_id IS NOT NULL LOOP\r\n        -- Récupérer les infos du parent\r\n        SELECT id, parent_affiliate_id, commission_rate\r\n        INTO v_affiliate_id, v_parent_id, v_commission_rate\r\n        FROM affiliate_profiles\r\n        WHERE id = v_parent_id AND is_active = true;\r\n\r\n        IF v_affiliate_id IS NOT NULL THEN\r\n            -- Calculer la commission indirecte (10% de la commission principale)\r\n            v_commission_amount := (v_commission_amount * 0.10);\r\n\r\n            -- Insérer la transaction de commission indirecte\r\n            INSERT INTO commission_transactions (\r\n                id,\r\n                affiliate_id,\r\n                order_id,\r\n                amount,\r\n                status,\r\n                created_at\r\n            ) VALUES (\r\n                gen_random_uuid(),\r\n                v_affiliate_id,\r\n                p_order_id,\r\n                v_commission_amount,\r\n                'PENDING',\r\n                v_current_date\r\n            );\r\n\r\n            -- Mettre à jour les statistiques du parent\r\n            UPDATE affiliate_profiles\r\n            SET \r\n                commission_balance = commission_balance + v_commission_amount,\r\n                total_earned = total_earned + v_commission_amount,\r\n                monthly_earnings = monthly_earnings + v_commission_amount,\r\n                updated_at = v_current_date\r\n            WHERE id = v_affiliate_id;\r\n        END IF;\r\n    END LOOP;\r\nEND;\r\n"
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
  },
  {
    "schema_name": "public",
    "function_name": "trigger_set_timestamp",
    "type": "Function",
    "source_code": "\r\nBEGIN\r\n  NEW.updated_at = NOW();\r\n  RETURN NEW;\r\nEND;\r\n"
  },
  {
    "schema_name": "public",
    "function_name": "trigger_update_affiliate_level",
    "type": "Function",
    "source_code": "\r\nBEGIN\r\n    IF NEW.total_earned <> OLD.total_earned THEN\r\n        CALL update_affiliate_level(NEW.id);\r\n    END IF;\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "schema_name": "public",
    "function_name": "update_affiliate_level",
    "type": "Procedure",
    "source_code": "\nDECLARE\n    v_total_earned DECIMAL;\n    v_new_level_id UUID;\nBEGIN\n    -- Récupérer le total des gains\n    SELECT total_earned INTO v_total_earned\n    FROM affiliate_profiles\n    WHERE id = p_affiliate_id;\n\n    -- Trouver le niveau approprié\n    SELECT id INTO v_new_level_id\n    FROM affiliate_levels\n    WHERE \"minEarnings\" <= v_total_earned\n    ORDER BY \"minEarnings\" DESC\n    LIMIT 1;\n\n    -- Mettre à jour le niveau de l'affilié\n    IF v_new_level_id IS NOT NULL THEN\n        UPDATE affiliate_profiles SET\n            level_id = v_new_level_id\n        WHERE id = p_affiliate_id;\n    END IF;\nEND;\n"
  },
  {
    "schema_name": "public",
    "function_name": "update_loyalty_points_updated_at",
    "type": "Function",
    "source_code": "\r\nBEGIN\r\n    NEW.\"updatedAt\" = CURRENT_TIMESTAMP;\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "schema_name": "public",
    "function_name": "update_order_items_updated_at",
    "type": "Function",
    "source_code": "\r\nBEGIN\r\n    NEW.\"updatedAt\" = CURRENT_TIMESTAMP;\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "schema_name": "public",
    "function_name": "update_orders_timestamp",
    "type": "Function",
    "source_code": "\r\nBEGIN\r\n    NEW.\"updatedAt\" = CURRENT_TIMESTAMP;\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "schema_name": "public",
    "function_name": "update_updated_at_column",
    "type": "Function",
    "source_code": "\r\nBEGIN\r\n    NEW.updated_at = NOW();\r\n    RETURN NEW;\r\nEND;\r\n"
  },
  {
    "schema_name": "storage",
    "function_name": "can_insert_object",
    "type": "Function",
    "source_code": "\nBEGIN\n  INSERT INTO \"storage\".\"objects\" (\"bucket_id\", \"name\", \"owner\", \"metadata\") VALUES (bucketid, name, owner, metadata);\n  -- hack to rollback the successful insert\n  RAISE sqlstate 'PT200' using\n  message = 'ROLLBACK',\n  detail = 'rollback successful insert';\nEND\n"
  },
  {
    "schema_name": "storage",
    "function_name": "extension",
    "type": "Function",
    "source_code": "\nDECLARE\n_parts text[];\n_filename text;\nBEGIN\n\tselect string_to_array(name, '/') into _parts;\n\tselect _parts[array_length(_parts,1)] into _filename;\n\t-- @todo return the last part instead of 2\n\treturn reverse(split_part(reverse(_filename), '.', 1));\nEND\n"
  },
  {
    "schema_name": "storage",
    "function_name": "filename",
    "type": "Function",
    "source_code": "\nDECLARE\n_parts text[];\nBEGIN\n\tselect string_to_array(name, '/') into _parts;\n\treturn _parts[array_length(_parts,1)];\nEND\n"
  },
  {
    "schema_name": "storage",
    "function_name": "foldername",
    "type": "Function",
    "source_code": "\nDECLARE\n_parts text[];\nBEGIN\n\tselect string_to_array(name, '/') into _parts;\n\treturn _parts[1:array_length(_parts,1)-1];\nEND\n"
  },
  {
    "schema_name": "storage",
    "function_name": "get_size_by_bucket",
    "type": "Function",
    "source_code": "\nBEGIN\n    return query\n        select sum((metadata->>'size')::int) as size, obj.bucket_id\n        from \"storage\".objects as obj\n        group by obj.bucket_id;\nEND\n"
  },
  {
    "schema_name": "storage",
    "function_name": "list_multipart_uploads_with_delimiter",
    "type": "Function",
    "source_code": "\nBEGIN\n    RETURN QUERY EXECUTE\n        'SELECT DISTINCT ON(key COLLATE \"C\") * from (\n            SELECT\n                CASE\n                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN\n                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))\n                    ELSE\n                        key\n                END AS key, id, created_at\n            FROM\n                storage.s3_multipart_uploads\n            WHERE\n                bucket_id = $5 AND\n                key ILIKE $1 || ''%'' AND\n                CASE\n                    WHEN $4 != '''' AND $6 = '''' THEN\n                        CASE\n                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN\n                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE \"C\" > $4\n                            ELSE\n                                key COLLATE \"C\" > $4\n                            END\n                    ELSE\n                        true\n                END AND\n                CASE\n                    WHEN $6 != '''' THEN\n                        id COLLATE \"C\" > $6\n                    ELSE\n                        true\n                    END\n            ORDER BY\n                key COLLATE \"C\" ASC, created_at ASC) as e order by key COLLATE \"C\" LIMIT $3'\n        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;\nEND;\n"
  },
  {
    "schema_name": "storage",
    "function_name": "list_objects_with_delimiter",
    "type": "Function",
    "source_code": "\nBEGIN\n    RETURN QUERY EXECUTE\n        'SELECT DISTINCT ON(name COLLATE \"C\") * from (\n            SELECT\n                CASE\n                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN\n                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))\n                    ELSE\n                        name\n                END AS name, id, metadata, updated_at\n            FROM\n                storage.objects\n            WHERE\n                bucket_id = $5 AND\n                name ILIKE $1 || ''%'' AND\n                CASE\n                    WHEN $6 != '''' THEN\n                    name COLLATE \"C\" > $6\n                ELSE true END\n                AND CASE\n                    WHEN $4 != '''' THEN\n                        CASE\n                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN\n                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE \"C\" > $4\n                            ELSE\n                                name COLLATE \"C\" > $4\n                            END\n                    ELSE\n                        true\n                END\n            ORDER BY\n                name COLLATE \"C\" ASC) as e order by name COLLATE \"C\" LIMIT $3'\n        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;\nEND;\n"
  },
  {
    "schema_name": "storage",
    "function_name": "operation",
    "type": "Function",
    "source_code": "\nBEGIN\n    RETURN current_setting('storage.operation', true);\nEND;\n"
  },
  {
    "schema_name": "storage",
    "function_name": "search",
    "type": "Function",
    "source_code": "\ndeclare\n  v_order_by text;\n  v_sort_order text;\nbegin\n  case\n    when sortcolumn = 'name' then\n      v_order_by = 'name';\n    when sortcolumn = 'updated_at' then\n      v_order_by = 'updated_at';\n    when sortcolumn = 'created_at' then\n      v_order_by = 'created_at';\n    when sortcolumn = 'last_accessed_at' then\n      v_order_by = 'last_accessed_at';\n    else\n      v_order_by = 'name';\n  end case;\n\n  case\n    when sortorder = 'asc' then\n      v_sort_order = 'asc';\n    when sortorder = 'desc' then\n      v_sort_order = 'desc';\n    else\n      v_sort_order = 'asc';\n  end case;\n\n  v_order_by = v_order_by || ' ' || v_sort_order;\n\n  return query execute\n    'with folders as (\n       select path_tokens[$1] as folder\n       from storage.objects\n         where objects.name ilike $2 || $3 || ''%''\n           and bucket_id = $4\n           and array_length(objects.path_tokens, 1) <> $1\n       group by folder\n       order by folder ' || v_sort_order || '\n     )\n     (select folder as \"name\",\n            null as id,\n            null as updated_at,\n            null as created_at,\n            null as last_accessed_at,\n            null as metadata from folders)\n     union all\n     (select path_tokens[$1] as \"name\",\n            id,\n            updated_at,\n            created_at,\n            last_accessed_at,\n            metadata\n     from storage.objects\n     where objects.name ilike $2 || $3 || ''%''\n       and bucket_id = $4\n       and array_length(objects.path_tokens, 1) = $1\n     order by ' || v_order_by || ')\n     limit $5\n     offset $6' using levels, prefix, search, bucketname, limits, offsets;\nend;\n"
  },
  {
    "schema_name": "storage",
    "function_name": "update_updated_at_column",
    "type": "Function",
    "source_code": "\nBEGIN\n    NEW.updated_at = now();\n    RETURN NEW; \nEND;\n"
  }
]