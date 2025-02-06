-- Ajouter une colonne pour le soft delete
ALTER TABLE articles 
ADD COLUMN "isDeleted" boolean DEFAULT false,
ADD COLUMN "deletedAt" timestamp with time zone;

-- Mettre à jour les vues et fonctions pour filtrer les articles supprimés
CREATE OR REPLACE VIEW active_articles AS
SELECT * FROM articles WHERE "isDeleted" = false;
