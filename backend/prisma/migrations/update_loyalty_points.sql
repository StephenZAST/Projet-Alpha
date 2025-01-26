-- Supprimer les triggers existants
DROP TRIGGER IF EXISTS update_loyalty_points_timestamp ON loyalty_points;
DROP FUNCTION IF EXISTS update_loyalty_points_updated_at CASCADE;
DROP TRIGGER IF EXISTS create_user_loyalty_points ON users;
DROP FUNCTION IF EXISTS initialize_user_loyalty_points CASCADE;

-- Supprimer les politiques existantes
DROP POLICY IF EXISTS "Users can view their own points" ON loyalty_points;
DROP POLICY IF EXISTS "Only system can modify points" ON loyalty_points;

-- La table existe déjà avec :
-- id (uuid)
-- user_id (uuid)
-- pointsBalance (int4)
-- totalEarned (int4)
-- createdAt (timestamptz)
-- updatedAt (timestamptz)

-- Activer Row Level Security
ALTER TABLE loyalty_points ENABLE ROW LEVEL SECURITY;

-- Créer les politiques RLS
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

-- Fonction pour initialiser les points d'un nouvel utilisateur
CREATE OR REPLACE FUNCTION initialize_user_loyalty_points()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO loyalty_points (user_id, "pointsBalance", "totalEarned")
    VALUES (NEW.id, 0, 0);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour créer automatiquement un enregistrement loyalty_points pour chaque nouvel utilisateur
CREATE TRIGGER create_user_loyalty_points
    AFTER INSERT ON users
    FOR EACH ROW
    EXECUTE FUNCTION initialize_user_loyalty_points();

-- Insérer les points pour les utilisateurs existants
INSERT INTO loyalty_points (user_id, "pointsBalance", "totalEarned")
SELECT id, 0, 0
FROM users u
WHERE NOT EXISTS (
    SELECT 1 FROM loyalty_points lp
    WHERE lp.user_id = u.id
);

-- Mettre à jour les commentaires
COMMENT ON TABLE loyalty_points IS 'Points de fidélité des utilisateurs';
COMMENT ON COLUMN loyalty_points.user_id IS 'ID de l''utilisateur';
COMMENT ON COLUMN loyalty_points."pointsBalance" IS 'Solde actuel des points';
COMMENT ON COLUMN loyalty_points."totalEarned" IS 'Total des points gagnés';
COMMENT ON COLUMN loyalty_points."createdAt" IS 'Date de création';
COMMENT ON COLUMN loyalty_points."updatedAt" IS 'Date de dernière mise à jour';

-- Afficher la structure finale de la table
SELECT column_name, data_type, column_default, is_nullable
FROM information_schema.columns 
WHERE table_name = 'loyalty_points'
ORDER BY ordinal_position;