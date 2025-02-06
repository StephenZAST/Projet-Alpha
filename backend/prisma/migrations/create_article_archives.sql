CREATE TABLE article_archives (
  id uuid PRIMARY KEY,
  original_id uuid REFERENCES articles(id),
  name varchar(255),
  description text,
  "basePrice" numeric,
  "premiumPrice" numeric,
  "categoryId" uuid,
  "createdAt" timestamp with time zone,
  "updatedAt" timestamp with time zone,
  "archivedAt" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  archived_reason text
);

-- Fonction pour archiver un article
CREATE OR REPLACE FUNCTION archive_article(p_article_id uuid, p_reason text)
RETURNS void AS
$$
BEGIN
  -- Copier l'article dans l'archive
  INSERT INTO article_archives (
    original_id, name, description, "basePrice", "premiumPrice", 
    "categoryId", "createdAt", "updatedAt", archived_reason
  )
  SELECT 
    id, name, description, "basePrice", "premiumPrice", 
    "categoryId", "createdAt", "updatedAt", p_reason
  FROM articles 
  WHERE id = p_article_id;

  -- Marquer l'article comme archivé
  UPDATE articles 
  SET "isDeleted" = true, 
      "deletedAt" = CURRENT_TIMESTAMP
  WHERE id = p_article_id;
END;
$$ LANGUAGE plpgsql;
