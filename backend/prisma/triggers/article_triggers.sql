-- Supprimons d'abord l'ancien trigger et sa fonction
DROP TRIGGER IF EXISTS update_articles_updatedat ON articles;
DROP FUNCTION IF EXISTS update_article_updatedat();

-- D'abord, vérifions et supprimons l'ancienne fonction si elle existe
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS update_article_updatedat() CASCADE;

-- Créons une nouvelle fonction globale pour tous les timestamps
CREATE OR REPLACE FUNCTION update_timestamp_column()
RETURNS TRIGGER AS
$$
BEGIN
    -- Gérer à la fois camelCase et snake_case
    IF TG_ARGV[0] = 'camelCase' THEN
        NEW."updatedAt" = CURRENT_TIMESTAMP;
    ELSE
        NEW.updated_at = CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

-- Créer le trigger spécifique pour la table articles
CREATE TRIGGER update_articles_timestamp
    BEFORE UPDATE ON articles
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp_column('camelCase');

-- Vérifions que tout est bien en place
SELECT tgname, proname, prosrc
FROM pg_trigger t
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE tgrelid = 'articles'::regclass;
