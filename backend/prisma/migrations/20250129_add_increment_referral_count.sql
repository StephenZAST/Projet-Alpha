-- Création de la fonction pour incrémenter le nombre de filleuls
CREATE OR REPLACE FUNCTION increment_referral_count(affiliate_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE affiliate_profiles
    SET 
        total_referrals = total_referrals + 1,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = affiliate_id;
END;
$$ LANGUAGE plpgsql;