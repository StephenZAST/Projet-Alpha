CREATE OR REPLACE FUNCTION initialize_default_pricing(
    p_service_id UUID,
    p_base_price DECIMAL DEFAULT 100
)
RETURNS VOID AS $$
BEGIN
    -- Supprimer les anciennes configurations si elles existent
    DELETE FROM weight_based_pricing WHERE service_id = p_service_id;
    
    -- Insérer les nouvelles configurations par tranches de poids
    INSERT INTO weight_based_pricing 
        (service_id, min_weight, max_weight, price_per_kg, created_at, updated_at)
    VALUES
        (p_service_id, 0, 5, p_base_price, NOW(), NOW()),
        (p_service_id, 5.1, 10, p_base_price * 0.95, NOW(), NOW()),
        (p_service_id, 10.1, 20, p_base_price * 0.90, NOW(), NOW()),
        (p_service_id, 20.1, 999999, p_base_price * 0.85, NOW(), NOW());
END;
$$ LANGUAGE plpgsql;
