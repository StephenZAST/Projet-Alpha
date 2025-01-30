-- Suppression des procédures existantes si elles existent
DROP PROCEDURE IF EXISTS process_affiliate_commission(UUID, DECIMAL, TEXT);
DROP PROCEDURE IF EXISTS update_affiliate_level(UUID);
DROP PROCEDURE IF EXISTS reset_monthly_earnings();
DROP FUNCTION IF EXISTS calculate_available_commission(UUID);
DROP FUNCTION IF EXISTS increment_referral_count(UUID);

-- Procédure pour calculer et distribuer les commissions d'affiliation
CREATE OR REPLACE PROCEDURE process_affiliate_commission(
    p_order_id UUID,
    p_order_amount DECIMAL,
    p_affiliate_code TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_affiliate_id UUID;
    v_direct_commission DECIMAL;
    v_indirect_commission DECIMAL;
    v_parent_id UUID;
BEGIN
    -- Récupérer l'ID de l'affilié
    SELECT id, parent_affiliate_id
    INTO v_affiliate_id, v_parent_id
    FROM affiliate_profiles
    WHERE affiliate_code = p_affiliate_code AND is_active = true;

    IF v_affiliate_id IS NULL THEN
        RAISE EXCEPTION 'Affiliate not found or inactive';
    END IF;

    -- Calculer la commission directe en utilisant total_referrals
    SELECT (p_order_amount * 0.4) * (
        CASE
            WHEN total_referrals >= 20 THEN 0.20 -- 20%
            WHEN total_referrals >= 10 THEN 0.15 -- 15%
            ELSE 0.10 -- 10%
        END
    )
    INTO v_direct_commission
    FROM affiliate_profiles
    WHERE id = v_affiliate_id;

    -- Créer la transaction de commission directe
    INSERT INTO commissionTransactions (
        id,
        affiliate_id,
        order_id,
        amount,
        type,
        status,
        created_at
    ) VALUES (
        gen_random_uuid(),
        v_affiliate_id,
        p_order_id,
        v_direct_commission,
        'COMMISSION',
        'APPROVED',
        NOW()
    );

    -- Mettre à jour le solde et les statistiques de l'affilié
    UPDATE affiliate_profiles SET
        commission_balance = commission_balance + v_direct_commission,
        total_earned = total_earned + v_direct_commission,
        monthly_earnings = monthly_earnings + v_direct_commission
    WHERE id = v_affiliate_id;

    -- Si l'affilié a un parent, traiter la commission indirecte
    IF v_parent_id IS NOT NULL THEN
        -- Calculer la commission indirecte (10% de la commission directe)
        v_indirect_commission := v_direct_commission * 0.1;

        -- Créer la transaction de commission indirecte
        INSERT INTO commissionTransactions (
            id,
            affiliate_id,
            order_id,
            amount,
            type,
            status,
            created_at
        ) VALUES (
            gen_random_uuid(),
            v_parent_id,
            p_order_id,
            v_indirect_commission,
            'INDIRECT_COMMISSION',
            'APPROVED',
            NOW()
        );

        -- Mettre à jour le solde et les statistiques du parent
        UPDATE affiliate_profiles SET
            commission_balance = commission_balance + v_indirect_commission,
            total_earned = total_earned + v_indirect_commission,
            monthly_earnings = monthly_earnings + v_indirect_commission
        WHERE id = v_parent_id;
    END IF;

    -- Mettre à jour le niveau de l'affilié
    CALL update_affiliate_level(v_affiliate_id);
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
    -- Récupérer le total des gains
    SELECT total_earned INTO v_total_earned
    FROM affiliate_profiles
    WHERE id = p_affiliate_id;

    -- Trouver le niveau approprié
    SELECT id INTO v_new_level_id
    FROM affiliate_levels
    WHERE "minEarnings" <= v_total_earned
    ORDER BY "minEarnings" DESC
    LIMIT 1;

    -- Mettre à jour le niveau de l'affilié
    IF v_new_level_id IS NOT NULL THEN
        UPDATE affiliate_profiles SET
            level_id = v_new_level_id
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
    SET monthly_earnings = 0
    WHERE is_active = true;
END;
$$;

-- Fonction pour calculer les commissions disponibles
CREATE OR REPLACE FUNCTION calculate_available_commission(
    p_affiliate_id UUID
) RETURNS DECIMAL
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_commission DECIMAL;
BEGIN
    SELECT COALESCE(commission_balance, 0)
    INTO v_total_commission
    FROM affiliate_profiles
    WHERE id = p_affiliate_id;

    RETURN v_total_commission;
END;
$$;

-- Fonction pour incrémenter le compteur de filleuls
CREATE OR REPLACE FUNCTION increment_referral_count(
    p_affiliate_id UUID
) RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_count INTEGER;
BEGIN
    UPDATE affiliate_profiles
    SET total_referrals = total_referrals + 1
    WHERE id = p_affiliate_id
    RETURNING total_referrals INTO v_new_count;

    RETURN v_new_count;
END;
$$;