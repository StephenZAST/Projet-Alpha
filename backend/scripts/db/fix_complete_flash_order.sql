-- Correction de la procédure complete_flash_order
CREATE OR REPLACE FUNCTION complete_flash_order(
  p_order_id UUID,
  p_service_id UUID,
  p_items JSON[],
  p_collection_date TIMESTAMP DEFAULT NULL,
  p_delivery_date TIMESTAMP DEFAULT NULL
) RETURNS JSON AS $$
DECLARE
  v_order orders%ROWTYPE;
  v_total DECIMAL := 0;
  v_result JSON;
BEGIN
  -- 1. Récupérer et vérifier la commande
  SELECT * INTO v_order
  FROM orders 
  WHERE id = p_order_id AND status = 'DRAFT'
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Commande flash non trouvée ou non modifiable';
  END IF;

  -- 2. Mettre à jour la commande
  UPDATE orders SET
    "serviceId" = p_service_id,
    status = 'PENDING',
    "collectionDate" = p_collection_date,
    "deliveryDate" = p_delivery_date,
    "updatedAt" = NOW()
  WHERE id = p_order_id
  RETURNING * INTO v_order;

  -- 3. Insérer les articles et calculer le total
  WITH inserted_items AS (
    INSERT INTO order_items (
      "orderId",
      "articleId",
      "serviceId",
      quantity,
      "unitPrice",
      "createdAt",
      "updatedAt"
    )
    SELECT 
      p_order_id,
      (item->>'articleId')::UUID,
      p_service_id,
      (item->>'quantity')::INT,
      (item->>'unitPrice')::DECIMAL,
      NOW(),
      NOW()
    FROM json_array_elements(array_to_json(p_items)::JSON) AS item
    RETURNING *
  )
  SELECT SUM(quantity * "unitPrice") INTO v_total FROM inserted_items;

  -- 4. Mettre à jour le total
  UPDATE orders 
  SET "totalAmount" = v_total
  WHERE id = p_order_id;

  -- 5. Construire le résultat JSON avec la structure exacte attendue
  WITH order_details AS (
    SELECT 
      o.*,
      json_build_object(
        'id', u.id,
        'email', u.email,
        'phone', u.phone,
        'lastName', u.last_name,
        'firstName', u.first_name
      ) as user_info,
      json_build_object(
        'id', a.id,
        'city', a.city,
        'street', a.street,
        'is_default', a.is_default,
        'postal_code', a.postal_code,
        'gps_latitude', a.gps_latitude,
        'gps_longitude', a.gps_longitude
      ) as address_info,
      COALESCE(json_agg(
        json_build_object(
          'id', i.id,
          'orderId', i."orderId",
          'articleId', i."articleId",
          'quantity', i.quantity,
          'unitPrice', i."unitPrice"
        )
      ) FILTER (WHERE i.id IS NOT NULL), '[]'::json) as items_info
    FROM orders o
    LEFT JOIN users u ON u.id = o."userId"
    LEFT JOIN addresses a ON a.id = o."addressId"
    LEFT JOIN order_items i ON i."orderId" = o.id
    WHERE o.id = p_order_id
    GROUP BY o.id, u.id, a.id
  )
  SELECT json_build_object(
    'data', json_build_object(
      'order', json_build_object(
        'id', od.id,
        'status', od.status,
        'userId', od."userId",
        'serviceId', od."serviceId",
        'addressId', od."addressId",
        'totalAmount', od."totalAmount",
        'createdAt', od."createdAt",
        'updatedAt', od."updatedAt",
        'user', od.user_info,
        'address', od.address_info,
        'items', od.items_info
      )
    )
  ) INTO v_result
  FROM order_details od;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql;
