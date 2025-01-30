-- Suppression des procédures existantes si elles existent
DROP PROCEDURE IF EXISTS process_withdrawal_request(UUID, DECIMAL);
DROP PROCEDURE IF EXISTS reject_withdrawal(UUID, TEXT);
DROP PROCEDURE IF EXISTS approve_withdrawal(UUID);

-- Procédure pour créer une demande de retrait
CREATE OR REPLACE PROCEDURE process_withdrawal_request(
    p_affiliate_id UUID,
    p_amount DECIMAL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_balance DECIMAL;
    v_min_withdrawal DECIMAL := 25000; -- Montant minimum de retrait en FCFA
BEGIN
    -- Vérifier le statut de l'affilié
    IF NOT EXISTS (
        SELECT 1 FROM affiliate_profiles
        WHERE id = p_affiliate_id
        AND is_active = true
        AND status = 'ACTIVE'
    ) THEN
        RAISE EXCEPTION 'Affiliate account is not active';
    END IF;

    -- Récupérer le solde actuel
    SELECT commission_balance INTO v_current_balance
    FROM affiliate_profiles
    WHERE id = p_affiliate_id;

    -- Vérifier le montant minimum
    IF p_amount < v_min_withdrawal THEN
        RAISE EXCEPTION 'Minimum withdrawal amount is % FCFA', v_min_withdrawal;
    END IF;

    -- Vérifier le solde disponible
    IF v_current_balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient balance. Available: % FCFA', v_current_balance;
    END IF;

    -- Créer la transaction de retrait
    INSERT INTO commission_transactions (
        id,
        affiliate_id,
        amount,
        type,
        status,
        created_at,
        updated_at
    ) VALUES (
        gen_random_uuid(),
        p_affiliate_id,
        -p_amount,
        'WITHDRAWAL',
        'PENDING',
        NOW(),
        NOW()
    );

    -- Mettre à jour le solde de l'affilié
    UPDATE affiliate_profiles
    SET commission_balance = commission_balance - p_amount,
        updated_at = NOW()
    WHERE id = p_affiliate_id;
END;
$$;

-- Procédure pour rejeter un retrait
CREATE OR REPLACE PROCEDURE reject_withdrawal(
    p_withdrawal_id UUID,
    p_reason TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_affiliate_id UUID;
    v_amount DECIMAL;
BEGIN
    -- Récupérer les informations du retrait
    SELECT affiliate_id, ABS(amount)
    INTO v_affiliate_id, v_amount
    FROM commission_transactions
    WHERE id = p_withdrawal_id
    AND type = 'WITHDRAWAL'
    AND status = 'PENDING';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Withdrawal not found or not in pending status';
    END IF;

    -- Mettre à jour le statut de la transaction
    UPDATE commission_transactions
    SET status = 'REJECTED',
        updated_at = NOW()
    WHERE id = p_withdrawal_id;

    -- Rembourser le montant sur le solde de l'affilié
    UPDATE affiliate_profiles
    SET commission_balance = commission_balance + v_amount,
        updated_at = NOW()
    WHERE id = v_affiliate_id;
END;
$$;

-- Procédure pour approuver un retrait
CREATE OR REPLACE PROCEDURE approve_withdrawal(
    p_withdrawal_id UUID
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Vérifier et mettre à jour le statut
    UPDATE commission_transactions
    SET status = 'APPROVED',
        updated_at = NOW()
    WHERE id = p_withdrawal_id
    AND type = 'WITHDRAWAL'
    AND status = 'PENDING';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Withdrawal not found or not in pending status';
    END IF;
END;
$$;