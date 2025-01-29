-- Procédure pour calculer et mettre à jour les commissions
CREATE OR REPLACE PROCEDURE process_affiliate_commission(
    p_order_id UUID,
    p_order_amount DECIMAL,
    p_affiliate_code VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_affiliate_id UUID;
    v_parent_id UUID;
    v_commission_rate DECIMAL;
    v_commission_amount DECIMAL;
    v_level_id UUID;
    v_current_date TIMESTAMPTZ;
BEGIN
    -- Récupérer la date courante
    v_current_date := CURRENT_TIMESTAMP;

    -- Récupérer l'affilié principal
    SELECT id, parent_affiliate_id, commission_rate, level_id
    INTO v_affiliate_id, v_parent_id, v_commission_rate, v_level_id
    FROM affiliate_profiles
    WHERE affiliate_code = p_affiliate_code AND is_active = true;

    IF v_affiliate_id IS NULL THEN
        RAISE EXCEPTION 'Affiliate not found or inactive';
    END IF;

    -- Calculer la commission principale
    v_commission_amount := (p_order_amount * v_commission_rate / 100);

    -- Insérer la transaction de commission principale
    INSERT INTO commission_transactions (
        id,
        affiliate_id,
        order_id,
        amount,
        status,
        created_at
    ) VALUES (
        gen_random_uuid(),
        v_affiliate_id,
        p_order_id,
        v_commission_amount,
        'PENDING',
        v_current_date
    );

    -- Mettre à jour les statistiques de l'affilié
    UPDATE affiliate_profiles
    SET 
        commission_balance = commission_balance + v_commission_amount,
        total_earned = total_earned + v_commission_amount,
        monthly_earnings = monthly_earnings + v_commission_amount,
        updated_at = v_current_date
    WHERE id = v_affiliate_id;

    -- Traiter la commission du parent si existant
    WHILE v_parent_id IS NOT NULL LOOP
        -- Récupérer les infos du parent
        SELECT id, parent_affiliate_id, commission_rate
        INTO v_affiliate_id, v_parent_id, v_commission_rate
        FROM affiliate_profiles
        WHERE id = v_parent_id AND is_active = true;

        IF v_affiliate_id IS NOT NULL THEN
            -- Calculer la commission indirecte (10% de la commission principale)
            v_commission_amount := (v_commission_amount * 0.10);

            -- Insérer la transaction de commission indirecte
            INSERT INTO commission_transactions (
                id,
                affiliate_id,
                order_id,
                amount,
                status,
                created_at
            ) VALUES (
                gen_random_uuid(),
                v_affiliate_id,
                p_order_id,
                v_commission_amount,
                'PENDING',
                v_current_date
            );

            -- Mettre à jour les statistiques du parent
            UPDATE affiliate_profiles
            SET 
                commission_balance = commission_balance + v_commission_amount,
                total_earned = total_earned + v_commission_amount,
                monthly_earnings = monthly_earnings + v_commission_amount,
                updated_at = v_current_date
            WHERE id = v_affiliate_id;
        END IF;
    END LOOP;
END;
$$;

-- Procédure pour mettre à jour le niveau d'un affilié
CREATE OR REPLACE PROCEDURE update_affiliate_level(
    p_affiliate_id UUID
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_earned DECIMAL;
    v_new_level_id UUID;
BEGIN
    -- Récupérer le total gagné par l'affilié
    SELECT total_earned
    INTO v_total_earned
    FROM affiliate_profiles
    WHERE id = p_affiliate_id;

    -- Trouver le niveau approprié
    SELECT id
    INTO v_new_level_id
    FROM affiliate_levels
    WHERE min_earnings <= v_total_earned
    ORDER BY min_earnings DESC
    LIMIT 1;

    -- Mettre à jour le niveau si nécessaire
    IF v_new_level_id IS NOT NULL THEN
        UPDATE affiliate_profiles
        SET 
            level_id = v_new_level_id,
            commission_rate = (
                SELECT commission_rate 
                FROM affiliate_levels 
                WHERE id = v_new_level_id
            ),
            updated_at = CURRENT_TIMESTAMP
        WHERE id = p_affiliate_id;
    END IF;
END;
$$;

-- Procédure pour réinitialiser les gains mensuels
CREATE OR REPLACE PROCEDURE reset_monthly_earnings()
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE affiliate_profiles
    SET 
        monthly_earnings = 0,
        updated_at = CURRENT_TIMESTAMP
    WHERE is_active = true;
END;
$$;

-- Fonction pour calculer la commission totale disponible
CREATE OR REPLACE FUNCTION calculate_available_commission(
    p_affiliate_id UUID
)
RETURNS DECIMAL
LANGUAGE plpgsql
AS $$
DECLARE
    v_total DECIMAL;
BEGIN
    SELECT COALESCE(SUM(amount), 0)
    INTO v_total
    FROM commission_transactions
    WHERE affiliate_id = p_affiliate_id
    AND status = 'PENDING';

    RETURN v_total;
END;
$$;

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_commission_transactions_status 
ON commission_transactions(status);

CREATE INDEX IF NOT EXISTS idx_affiliate_profiles_total_earned 
ON affiliate_profiles(total_earned);

CREATE INDEX IF NOT EXISTS idx_affiliate_profiles_monthly_earnings 
ON affiliate_profiles(monthly_earnings);

-- Trigger pour mettre à jour automatiquement le niveau après une commission
CREATE OR REPLACE FUNCTION trigger_update_affiliate_level()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.total_earned <> OLD.total_earned THEN
        CALL update_affiliate_level(NEW.id);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER after_affiliate_earnings_update
    AFTER UPDATE OF total_earned ON affiliate_profiles
    FOR EACH ROW
    EXECUTE FUNCTION trigger_update_affiliate_level();