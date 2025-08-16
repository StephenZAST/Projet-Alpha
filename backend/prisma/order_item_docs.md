\dS order_items


Table "public.order_items"
Column	Type	Collation	Nullable	Default
id	uuid		not null	uuid_generate_v4()
orderId	uuid		not null	
articleId	uuid		not null	
serviceId	uuid		not null	
quantity	integer		not null	
unitPrice	numeric		not null	
createdAt	timestamp with time zone		not null	CURRENT_TIMESTAMP
updatedAt	timestamp with time zone		not null	CURRENT_TIMESTAMP
isPremium	boolean			false
Indexes:
"order_items_pkey" PRIMARY KEY, btree (id)
Check constraints:
"order_items_quantity_check" CHECK (quantity > 0)
"order_items_unitprice_check" CHECK ("unitPrice" >= 0::numeric)
Foreign-key constraints:
"order_items_articleId_fkey" FOREIGN KEY ("articleId") REFERENCES articles(id) ON UPDATE CASCADE ON DELETE RESTRICT
"order_items_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES orders(id) ON UPDATE CASCADE ON DELETE RESTRICT
Triggers:
log_order_items_insert BEFORE INSERT ON order_items FOR EACH ROW EXECUTE FUNCTION log_order_items_insert()
order_items_total_update AFTER INSERT OR DELETE OR UPDATE ON order_items FOR EACH ROW EXECUTE FUNCTION update_order_total()
Disabled user triggers:
ensure_valid_order_items BEFORE INSERT OR UPDATE ON order_items FOR EACH ROW EXECUTE FUNCTION validate_order_items_constraint()



Lister toutes les fonctions qui contiennent "order_item" dans leur nom


SELECT proname, pg_get_functiondef(oid) 
FROM pg_proc 
WHERE proname ILIKE '%order_item%';



#	proname	pg_get_functiondef
1	update_order_items_updated_at	CREATE OR REPLACE FUNCTION public.update_order_items_updated_at() RETURNS trigger LANGUAGE plpgsql AS $function$ BEGIN NEW.updated_at = CURRENT_TIMESTAMP; RETURN NEW; END; $function$
2	validate_order_items_constraint	CREATE OR REPLACE FUNCTION public.validate_order_items_constraint() RETURNS trigger LANGUAGE plpgsql AS $function$ BEGIN -- Vérification de la quantité IF NEW.quantity <= 0 THEN RAISE EXCEPTION 'La quantité doit être supérieure à zéro'; END IF; -- Vérification du prix unitaire IF NEW."unitPrice" <= 0 THEN RAISE EXCEPTION 'Le prix unitaire doit être supérieur à zéro'; END IF; -- Vérification du poids si applicable IF NEW.weight IS NOT NULL AND NEW.weight <= 0 THEN RAISE EXCEPTION 'Le poids doit être supérieur à zéro'; END IF; -- Calcul automatique du total NEW.total := NEW.quantity * NEW."unitPrice"; -- Mise à jour du timestamp NEW.updated_at := CURRENT_TIMESTAMP; RETURN NEW; END; $function$
3	log_order_items_insert	CREATE OR REPLACE FUNCTION public.log_order_items_insert() RETURNS trigger LANGUAGE plpgsql AS $function$ BEGIN RAISE NOTICE 'Insert order_items: %', row_to_json(NEW); RETURN NEW; END; $function$



. Lister toutes les fonctions qui font référence à order_items dans leur code source


\df *order_item*



SELECT 
    proname AS function_name,
    pg_get_functiondef(oid) AS definition
FROM pg_proc 
WHERE pronamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
AND pg_get_functiondef(oid) ILIKE '%order_items%';




#	function_name	definition
1	update_order_items_updated_at	CREATE OR REPLACE FUNCTION public.update_order_items_updated_at() RETURNS trigger LANGUAGE plpgsql AS $function$ BEGIN NEW.updated_at = CURRENT_TIMESTAMP; RETURN NEW; END; $function$
2	calculate_order_total	CREATE OR REPLACE FUNCTION public.calculate_order_total(order_id_param uuid) RETURNS numeric LANGUAGE plpgsql AS $function$ BEGIN RETURN COALESCE(( SELECT SUM(quantity * "unitPrice") FROM order_items WHERE "orderId" = order_id_param ), 0); END; $function$
3	get_paginated_orders	CREATE OR REPLACE FUNCTION public.get_paginated_orders(p_page integer, p_limit integer, p_status text DEFAULT NULL::text, p_sort_field text DEFAULT 'created_at'::text, p_sort_order text DEFAULT 'desc'::text) RETURNS TABLE(data jsonb, total_count bigint) LANGUAGE plpgsql AS $function$ DECLARE v_offset integer; v_where text := 'WHERE 1=1'; v_order_by text; BEGIN -- Calculer l'offset v_offset := (p_page - 1) * p_limit; -- Ajouter le filtre de statut si fourni IF p_status IS NOT NULL THEN v_where := v_where || format(' AND status = %L', p_status); END IF; -- Construire ORDER BY v_order_by := format(' ORDER BY %I %s', p_sort_field, p_sort_order); -- Retourner les résultats RETURN QUERY EXECUTE format(' WITH ordered_orders AS ( SELECT jsonb_build_object( ''id'', o.id, ''userId'', o."userId", ''serviceId'', o."serviceId", ''addressId'', o."addressId", ''status'', o.status, ''total'', o.total, ''createdAt'', o.created_at, ''updatedAt'', o.updated_at, ''items'', COALESCE( jsonb_agg( jsonb_build_object( ''id'', oi.id, ''articleId'', oi."articleId", ''quantity'', oi.quantity, ''unitPrice'', oi."unitPrice" ) ) FILTER (WHERE oi.id IS NOT NULL), ''[]''::jsonb ) ) as order_data FROM orders o LEFT JOIN order_items oi ON o.id = oi."orderId" %s GROUP BY o.id %s LIMIT %s OFFSET %s ) SELECT array_to_json(array_agg(order_data))::jsonb as data, (SELECT COUNT(*) FROM orders o %s) as total_count FROM ordered_orders; ', v_where, v_order_by, p_limit, v_offset, v_where); END; $function$
4	validate_order_items_constraint	CREATE OR REPLACE FUNCTION public.validate_order_items_constraint() RETURNS trigger LANGUAGE plpgsql AS $function$ BEGIN -- Vérification de la quantité IF NEW.quantity <= 0 THEN RAISE EXCEPTION 'La quantité doit être supérieure à zéro'; END IF; -- Vérification du prix unitaire IF NEW."unitPrice" <= 0 THEN RAISE EXCEPTION 'Le prix unitaire doit être supérieur à zéro'; END IF; -- Mise à jour du timestamp NEW.updated_at := CURRENT_TIMESTAMP; RETURN NEW; END; $function$
5	log_order_items_insert	CREATE OR REPLACE FUNCTION public.log_order_items_insert() RETURNS trigger LANGUAGE plpgsql AS $function$ BEGIN RAISE NOTICE 'Insert order_items: %', row_to_json(NEW); RETURN NEW; END; $function$




SELECT t.tgname, p.proname 
FROM pg_trigger t 
JOIN pg_class c ON t.tgrelid = c.oid 
JOIN pg_proc p ON t.tgfoid = p.oid 
WHERE c.relname = 'order_items';




#	tgname	proname
1	RI_ConstraintTrigger_c_311345	RI_FKey_check_upd
2	RI_ConstraintTrigger_c_311339	RI_FKey_check_ins
3	RI_ConstraintTrigger_c_311340	RI_FKey_check_upd
4	RI_ConstraintTrigger_c_311344	RI_FKey_check_ins
5	ensure_valid_order_items	validate_order_items_constraint
6	log_order_items_insert	log_order_items_insert
7	order_items_total_update	update_order_total



fonction filtrer par schema

#	function_name	definition
1	update_order_items_updated_at	CREATE OR REPLACE FUNCTION public.update_order_items_updated_at() RETURNS trigger LANGUAGE plpgsql AS $function$ BEGIN NEW.updated_at = CURRENT_TIMESTAMP; RETURN NEW; END; $function$
2	calculate_order_total	CREATE OR REPLACE FUNCTION public.calculate_order_total(order_id_param uuid) RETURNS numeric LANGUAGE plpgsql AS $function$ BEGIN RETURN COALESCE(( SELECT SUM(quantity * "unitPrice") FROM order_items WHERE "orderId" = order_id_param ), 0); END; $function$
3	get_paginated_orders	CREATE OR REPLACE FUNCTION public.get_paginated_orders(p_page integer, p_limit integer, p_status text DEFAULT NULL::text, p_sort_field text DEFAULT 'created_at'::text, p_sort_order text DEFAULT 'desc'::text) RETURNS TABLE(data jsonb, total_count bigint) LANGUAGE plpgsql AS $function$ DECLARE v_offset integer; v_where text := 'WHERE 1=1'; v_order_by text; BEGIN -- Calculer l'offset v_offset := (p_page - 1) * p_limit; -- Ajouter le filtre de statut si fourni IF p_status IS NOT NULL THEN v_where := v_where || format(' AND status = %L', p_status); END IF; -- Construire ORDER BY v_order_by := format(' ORDER BY %I %s', p_sort_field, p_sort_order); -- Retourner les résultats RETURN QUERY EXECUTE format(' WITH ordered_orders AS ( SELECT jsonb_build_object( ''id'', o.id, ''userId'', o."userId", ''serviceId'', o."serviceId", ''addressId'', o."addressId", ''status'', o.status, ''total'', o.total, ''createdAt'', o.created_at, ''updatedAt'', o.updated_at, ''items'', COALESCE( jsonb_agg( jsonb_build_object( ''id'', oi.id, ''articleId'', oi."articleId", ''quantity'', oi.quantity, ''unitPrice'', oi."unitPrice" ) ) FILTER (WHERE oi.id IS NOT NULL), ''[]''::jsonb ) ) as order_data FROM orders o LEFT JOIN order_items oi ON o.id = oi."orderId" %s GROUP BY o.id %s LIMIT %s OFFSET %s ) SELECT array_to_json(array_agg(order_data))::jsonb as data, (SELECT COUNT(*) FROM orders o %s) as total_count FROM ordered_orders; ', v_where, v_order_by, p_limit, v_offset, v_where); END; $function$
4	validate_order_items_constraint	CREATE OR REPLACE FUNCTION public.validate_order_items_constraint() RETURNS trigger LANGUAGE plpgsql AS $function$ BEGIN -- Vérification de la quantité IF NEW.quantity <= 0 THEN RAISE EXCEPTION 'La quantité doit être supérieure à zéro'; END IF; -- Vérification du prix unitaire IF NEW."unitPrice" <= 0 THEN RAISE EXCEPTION 'Le prix unitaire doit être supérieur à zéro'; END IF; -- Vérification du poids si applicable IF NEW.weight IS NOT NULL AND NEW.weight <= 0 THEN RAISE EXCEPTION 'Le poids doit être supérieur à zéro'; END IF; -- Calcul automatique du total NEW.total := NEW.quantity * NEW."unitPrice"; -- Mise à jour du timestamp NEW.updated_at := CURRENT_TIMESTAMP; RETURN NEW; END; $function$









CREATE OR REPLACE FUNCTION log_order_items_insert()
RETURNS trigger AS $$
BEGIN
  RAISE NOTICE 'Insert order_items: %', row_to_json(NEW);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_order_items_insert
BEFORE INSERT ON public.order_items
FOR EACH ROW EXECUTE FUNCTION log_order_items_insert();




CREATE OR REPLACE FUNCTION public.update_order_total()
RETURNS trigger
LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE orders
    SET "totalAmount" = calculate_order_total(NEW."orderId"),
        "updatedAt" = CURRENT_TIMESTAMP
    WHERE id = NEW."orderId";
    RETURN NEW;
END;
$function$;


