-- Script corrigé pour ajouter les contraintes de clés étrangères

-- Ajouter les contraintes de clés étrangères (avec gestion des erreurs)
DO $$
BEGIN
    -- Contrainte pour reward_claims -> users
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_reward_claims_user' 
        AND table_name = 'reward_claims'
    ) THEN
        ALTER TABLE reward_claims ADD CONSTRAINT fk_reward_claims_user 
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
    END IF;

    -- Contrainte pour reward_claims -> rewards
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_reward_claims_reward' 
        AND table_name = 'reward_claims'
    ) THEN
        ALTER TABLE reward_claims ADD CONSTRAINT fk_reward_claims_reward 
            FOREIGN KEY (reward_id) REFERENCES rewards(id) ON DELETE CASCADE;
    END IF;
END $$;

-- Ajouter des index pour les performances
CREATE INDEX IF NOT EXISTS idx_rewards_active ON rewards(is_active);
CREATE INDEX IF NOT EXISTS idx_rewards_type ON rewards(type);
CREATE INDEX IF NOT EXISTS idx_reward_claims_status ON reward_claims(status);
CREATE INDEX IF NOT EXISTS idx_reward_claims_user ON reward_claims(user_id);
CREATE INDEX IF NOT EXISTS idx_reward_claims_reward ON reward_claims(reward_id);

-- Insérer quelques récompenses par défaut
INSERT INTO rewards (id, name, description, points_cost, type, discount_value, discount_type, is_active) 
VALUES 
    (uuid_generate_v4(), 'Réduction 5%', 'Réduction de 5% sur votre prochaine commande', 100, 'DISCOUNT', 5, 'PERCENTAGE', true),
    (uuid_generate_v4(), 'Réduction 10%', 'Réduction de 10% sur votre prochaine commande', 200, 'DISCOUNT', 10, 'PERCENTAGE', true),
    (uuid_generate_v4(), 'Livraison gratuite', 'Livraison gratuite pour votre prochaine commande', 150, 'FREE_DELIVERY', NULL, NULL, true),
    (uuid_generate_v4(), 'Réduction 1000 FCFA', 'Réduction de 1000 FCFA sur votre prochaine commande', 300, 'DISCOUNT', 1000, 'FIXED_AMOUNT', true)
ON CONFLICT (id) DO NOTHING;

-- Ajouter des commentaires
COMMENT ON TABLE rewards IS 'Table des récompenses du système de fidélité';
COMMENT ON TABLE reward_claims IS 'Table des demandes de récompenses des utilisateurs';