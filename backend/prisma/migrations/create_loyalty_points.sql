-- Vérifier la structure de la table users
SELECT column_name, data_type, column_default, is_nullable
FROM information_schema.columns 
WHERE table_name = 'users';

-- Supprimer les politiques existantes
DROP POLICY IF EXISTS "Users can view their own points" ON loyalty_points;
DROP POLICY IF EXISTS "Only system can modify points" ON loyalty_points;

-- Créer la table loyalty_points si elle n'existe pas
CREATE TABLE IF NOT EXISTS loyalty_points (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    "pointsBalance" NUMERIC DEFAULT 0 NOT NULL,
    "lastUpdated" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "createdAt" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT positive_balance CHECK ("pointsBalance" >= 0)
);

-- Créer un index sur user_id pour optimiser les recherches
CREATE INDEX IF NOT EXISTS idx_loyalty_points_user_id ON loyalty_points(user_id);

-- Activer Row Level Security
ALTER TABLE loyalty_points ENABLE ROW LEVEL SECURITY;

-- Politiques RLS
CREATE POLICY "Users can view their own points"
    ON loyalty_points
    FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY "Only system can modify points"
    ON loyalty_points
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.id = auth.uid()
            AND users.role IN ('ADMIN', 'SUPER_ADMIN')
        )
    );

-- Supprimer le trigger existant s'il existe
DROP TRIGGER IF EXISTS update_loyalty_points_timestamp ON loyalty_points;
DROP FUNCTION IF EXISTS update_loyalty_points_updated_at();

-- Créer la fonction et le trigger pour mettre à jour updatedAt
CREATE OR REPLACE FUNCTION update_loyalty_points_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_loyalty_points_timestamp
    BEFORE UPDATE ON loyalty_points
    FOR EACH ROW
    EXECUTE FUNCTION update_loyalty_points_updated_at();

-- Supprimer le trigger existant s'il existe
DROP TRIGGER IF EXISTS create_user_loyalty_points ON users;
DROP FUNCTION IF EXISTS initialize_user_loyalty_points();

-- Fonction pour initialiser les points d'un nouvel utilisateur
CREATE OR REPLACE FUNCTION initialize_user_loyalty_points()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO loyalty_points (user_id, "pointsBalance")
    VALUES (NEW.id, 0);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour créer automatiquement un enregistrement loyalty_points pour chaque nouvel utilisateur
CREATE TRIGGER create_user_loyalty_points
    AFTER INSERT ON users
    FOR EACH ROW
    EXECUTE FUNCTION initialize_user_loyalty_points();

-- Insérer les points pour les utilisateurs existants
INSERT INTO loyalty_points (user_id, "pointsBalance")
SELECT id, 0
FROM users u
WHERE NOT EXISTS (
    SELECT 1 FROM loyalty_points lp
    WHERE lp.user_id = u.id
);

-- Commentaires
COMMENT ON TABLE loyalty_points IS 'Points de fidélité des utilisateurs';
COMMENT ON COLUMN loyalty_points.user_id IS 'ID de l''utilisateur';
COMMENT ON COLUMN loyalty_points."pointsBalance" IS 'Solde actuel des points';
COMMENT ON COLUMN loyalty_points."lastUpdated" IS 'Dernière mise à jour du solde';

-- Afficher la structure finale de la table
SELECT column_name, data_type, column_default, is_nullable
FROM information_schema.columns 
WHERE table_name = 'loyalty_points';