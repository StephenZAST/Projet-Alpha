CREATE OR REPLACE FUNCTION calculate_weight_price(
    p_service_id UUID,
    p_weight DECIMAL
)
RETURNS DECIMAL AS $$
DECLARE
    v_price DECIMAL;
BEGIN
    -- Log des paramètres pour le débogage
    RAISE NOTICE 'Calculating price for service_id: % and weight: %', p_service_id, p_weight;

    SELECT price_per_kg * p_weight INTO v_price
    FROM weight_based_pricing
    WHERE service_id = p_service_id
    AND p_weight BETWEEN min_weight AND max_weight;

    IF v_price IS NULL THEN
        RAISE EXCEPTION 'No pricing found for service_id: % and weight: %', p_service_id, p_weight;
    END IF;

    RETURN v_price;
END;
$$ LANGUAGE plpgsql;
