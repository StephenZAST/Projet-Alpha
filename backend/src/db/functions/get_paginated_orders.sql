CREATE OR REPLACE FUNCTION get_paginated_orders(
  p_page INTEGER,
  p_limit INTEGER,
  p_status TEXT DEFAULT NULL,
  p_sort_field TEXT DEFAULT 'created_at',
  p_sort_order TEXT DEFAULT 'desc'
)
RETURNS TABLE (
  data JSONB,
  total_count BIGINT
) AS $$
DECLARE
  v_offset INTEGER;
  v_where TEXT := 'TRUE';
  v_order_by TEXT;
BEGIN
  -- Calculer l'offset
  v_offset := (p_page - 1) * p_limit;
  
  -- Construire la clause WHERE pour le filtrage
  IF p_status IS NOT NULL THEN
    v_where := v_where || ' AND status = ' || quote_literal(p_status);
  END IF;

  -- Construire la clause ORDER BY sécurisée
  v_order_by := CASE 
    WHEN p_sort_field IN ('created_at', 'updated_at', 'total_amount', 'status') THEN
      format('o.%I %s', p_sort_field, 
        CASE WHEN upper(p_sort_order) = 'ASC' THEN 'ASC' ELSE 'DESC' END)
    ELSE 'o.created_at DESC'
  END;

  RETURN QUERY EXECUTE format('
    WITH total AS (
      SELECT COUNT(*) AS count
      FROM orders o
      WHERE %s
    ),
    paginated_data AS (
      SELECT 
        o.*,
        jsonb_build_object(
          ''id'', u.id,
          ''firstName'', u.first_name,
          ''lastName'', u.last_name,
          ''email'', u.email,
          ''phone'', u.phone
        ) AS user,
        jsonb_build_object(
          ''id'', s.id,
          ''name'', s.name,
          ''price'', s.price
        ) AS service,
        jsonb_build_object(
          ''id'', a.id,
          ''street'', a.street,
          ''city'', a.city,
          ''postal_code'', a.postal_code,
          ''gps_latitude'', a.gps_latitude,
          ''gps_longitude'', a.gps_longitude
        ) AS address,
        jsonb_build_object(
          ''note'', n.note
        ) AS metadata,
        (
          SELECT jsonb_agg(jsonb_build_object(
            ''id'', oi.id,
            ''articleId'', oi.article_id,
            ''quantity'', oi.quantity,
            ''unitPrice'', oi.unit_price
          ))
          FROM order_items oi
          WHERE oi.order_id = o.id
        ) AS items
      FROM orders o
      LEFT JOIN users u ON o.user_id = u.id
      LEFT JOIN services s ON o.service_id = s.id
      LEFT JOIN addresses a ON o.address_id = a.id
      LEFT JOIN order_notes n ON n.order_id = o.id
      WHERE %s
      ORDER BY %s
      LIMIT %L OFFSET %L
    )
    SELECT 
      COALESCE(jsonb_agg(
        jsonb_build_object(
          ''id'', pd.id,
          ''userId'', pd.user_id,
          ''addressId'', pd.address_id,
          ''serviceId'', pd.service_id,
          ''status'', pd.status,
          ''totalAmount'', pd.total_amount,
          ''createdAt'', pd.created_at,
          ''updatedAt'', pd.updated_at,
          ''user'', pd.user,
          ''service'', pd.service,
          ''address'', pd.address,
          ''metadata'', pd.metadata,
          ''items'', pd.items
        )
      ), ''[]''::jsonb) AS data,
      (SELECT count FROM total) AS total_count
    FROM paginated_data pd',
    v_where,
    v_where,
    v_order_by,
    p_limit,
    v_offset
  );
END;
$$ LANGUAGE plpgsql;
