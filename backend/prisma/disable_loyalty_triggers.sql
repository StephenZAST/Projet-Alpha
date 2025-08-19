-- Désactivation du trigger et de la fonction de fidélité
DROP TRIGGER IF EXISTS after_point_transaction ON public.point_transactions;
DROP FUNCTION IF EXISTS public.update_loyalty_points_balance;
