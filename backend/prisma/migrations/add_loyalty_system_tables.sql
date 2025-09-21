-- Migration pour compléter les tables du système de fidélité

-- Compléter la table rewards
ALTER TABLE rewards ADD COLUMN IF NOT EXISTS name VARCHAR NOT NULL DEFAULT 'Récompense';
ALTER TABLE rewards ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE rewards ADD COLUMN IF NOT EXISTS points_cost INTEGER NOT NULL DEFAULT 100;
ALTER TABLE rewards ADD COLUMN IF NOT EXISTS type VARCHAR NOT NULL DEFAULT 'DISCOUNT';
ALTER TABLE rewards ADD COLUMN IF NOT EXISTS discount_value DECIMAL;
ALTER TABLE rewards ADD COLUMN IF NOT EXISTS discount_type VARCHAR;
ALTER TABLE rewards ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE rewards ADD COLUMN IF NOT EXISTS max_redemptions INTEGER;
ALTER TABLE rewards ADD COLUMN IF NOT EXISTS current_redemptions INTEGER DEFAULT 0;
ALTER TABLE rewards ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE rewards ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Compléter la table reward_claims
ALTER TABLE reward_claims ADD COLUMN IF NOT EXISTS user_id UUID;
ALTER TABLE reward_claims ADD COLUMN IF NOT EXISTS reward_id UUID;
ALTER TABLE reward_claims ADD COLUMN IF NOT EXISTS points_used INTEGER NOT NULL DEFAULT 0;
ALTER TABLE reward_claims ADD COLUMN IF NOT EXISTS status VARCHAR NOT NULL DEFAULT 'PENDING';
ALTER TABLE reward_claims ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE reward_claims ADD COLUMN IF NOT EXISTS processed_at TIMESTAMPTZ;
ALTER TABLE reward_claims ADD COLUMN IF NOT EXISTS used_at TIMESTAMPTZ;
ALTER TABLE reward_claims ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

-- Ajouter les contraintes de clés étrangères
ALTER TABLE reward_claims ADD CONSTRAINT IF NOT EXISTS fk_reward_claims_user 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE reward_claims ADD CONSTRAINT IF NOT EXISTS fk_reward_claims_reward 
    FOREIGN KEY (reward_id) REFERENCES rewards(id) ON DELETE CASCADE;

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

COMMENT ON TABLE rewards IS 'Table des récompenses du système de fidélité';
COMMENT ON TABLE reward_claims IS 'Table des demandes de récompenses des utilisateurs';