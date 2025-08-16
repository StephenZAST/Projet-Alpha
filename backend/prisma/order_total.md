SELECT tgname, pg_get_triggerdef(oid)
FROM pg_trigger
WHERE tgrelid = 'order_items'::regclass
  AND NOT tgisinternal;


  #	tgname	pg_get_triggerdef
1	log_order_items_insert	CREATE TRIGGER log_order_items_insert BEFORE INSERT ON public.order_items FOR EACH ROW EXECUTE FUNCTION log_order_items_insert()
2	order_items_total_update	CREATE TRIGGER order_items_total_update AFTER INSERT OR DELETE OR UPDATE ON public.order_items FOR EACH ROW EXECUTE FUNCTION update_order_total()
3	ensure_valid_order_items	CREATE TRIGGER ensure_valid_order_items BEFORE INSERT OR UPDATE ON public.order_items FOR EACH ROW EXECUTE FUNCTION validate_order_items_constraint()



#	proname	pg_get_functiondef
1	calculate_order_total	CREATE OR REPLACE FUNCTION public.calculate_order_total(order_id_param uuid) RETURNS numeric LANGUAGE plpgsql AS $function$ BEGIN RETURN COALESCE(( SELECT SUM(quantity * "unitPrice") FROM order_items WHERE "orderId" = order_id_param ), 0); END; $function$
2	update_order_total	CREATE OR REPLACE FUNCTION public.update_order_total() RETURNS trigger LANGUAGE plpgsql AS $function$ BEGIN UPDATE orders SET "totalAmount" = calculate_order_total(NEW."orderId"), "updatedAt" = CURRENT_TIMESTAMP WHERE id = NEW."orderId"; RETURN NEW; END; $function$

