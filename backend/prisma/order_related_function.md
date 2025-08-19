ok voila la definition de chaque fonction 


 Définition de update_order_total()


#	pg_get_functiondef
1	CREATE OR REPLACE FUNCTION public.update_order_total() RETURNS trigger LANGUAGE plpgsql AS $function$ BEGIN UPDATE orders SET "totalAmount" = calculate_order_total(NEW."orderId"), "updatedAt" = CURRENT_TIMESTAMP WHERE id = NEW."orderId"; RETURN NEW; END; $function$


Définition de validate_order_items_constraint()

#	pg_get_functiondef
1	CREATE OR REPLACE FUNCTION public.validate_order_items_constraint() RETURNS trigger LANGUAGE plpgsql AS $function$ BEGIN -- Vérification de la quantité IF NEW.quantity <= 0 THEN RAISE EXCEPTION 'La quantité doit être supérieure à zéro'; END IF; -- Vérification du prix unitaire IF NEW."unitPrice" <= 0 THEN RAISE EXCEPTION 'Le prix unitaire doit être supérieur à zéro'; END IF; -- Vérification du poids si applicable IF NEW.weight IS NOT NULL AND NEW.weight <= 0 THEN RAISE EXCEPTION 'Le poids doit être supérieur à zéro'; END IF; -- Calcul automatique du total NEW.total = NEW.quantity * NEW."unitPrice"; -- Mise à jour du timestamp (correction camelCase) NEW."updatedAt" = CURRENT_TIMESTAMP; RETURN NEW; END; $function$


Définition de sync_order_note()

#	pg_get_functiondef
1	CREATE OR REPLACE FUNCTION public.sync_order_note() RETURNS trigger LANGUAGE plpgsql AS $function$ BEGIN IF TG_OP = 'INSERT' THEN UPDATE orders SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.order_id; ELSIF TG_OP = 'UPDATE' THEN IF OLD.note <> NEW.note THEN UPDATE orders SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.order_id; END IF; END IF; RETURN NEW; END; $function$



Définition de update_timestamp()

#	pg_get_functiondef
1	CREATE OR REPLACE FUNCTION public.update_timestamp() RETURNS trigger LANGUAGE plpgsql AS $function$ BEGIN IF TG_OP = 'UPDATE' THEN NEW.updated_at = CURRENT_TIMESTAMP; ELSE -- Pour INSERT NEW.created_at = COALESCE(NEW.created_at, CURRENT_TIMESTAMP); NEW.updated_at = CURRENT_TIMESTAMP; END IF; RETURN NEW; END; $function$