-- 1. Supprimer la table existante
DROP TABLE IF EXISTS order_items;

-- 2. Recréer la table avec les bonnes relations
CREATE TABLE order_items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    orderId UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    articleId UUID NOT NULL REFERENCES articles(id) ON DELETE RESTRICT,
    serviceId UUID NOT NULL REFERENCES services(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unitPrice NUMERIC NOT NULL CHECK (unitPrice >= 0),
    createdAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updatedAt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    
    -- Ajouter un index pour améliorer les performances des requêtes
    CONSTRAINT order_items_unique_article UNIQUE (orderId, articleId)
);

-- 3. Créer des index pour optimiser les requêtes
CREATE INDEX idx_order_items_order_id ON order_items(orderId);
CREATE INDEX idx_order_items_article_id ON order_items(articleId);

-- 4. Activer Row Level Security
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- 5. Créer les politiques d'accès
-- Politique pour la sélection - Les utilisateurs peuvent voir leurs propres items
CREATE POLICY "Users can view their own order items"
    ON order_items
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 
            FROM orders o
            WHERE o.id = order_items.orderId
            AND o."userId" = auth.uid()
        )
    );

-- Politique pour l'insertion - Les utilisateurs peuvent créer des items pour leurs commandes
CREATE POLICY "Users can create items for their orders"
    ON order_items
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 
            FROM orders o
            WHERE o.id = order_items.orderId
            AND o."userId" = auth.uid()
        )
    );

-- Politique pour la mise à jour - Les utilisateurs peuvent modifier leurs propres items
CREATE POLICY "Users can update their own order items"
    ON order_items
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 
            FROM orders o
            WHERE o.id = order_items.orderId
            AND o."userId" = auth.uid()
        )
    );

-- Politique pour la suppression - Les utilisateurs peuvent supprimer leurs propres items
CREATE POLICY "Users can delete their own order items"
    ON order_items
    FOR DELETE
    USING (
        EXISTS (
            SELECT 1 
            FROM orders o
            WHERE o.id = order_items.orderId
            AND o."userId" = auth.uid()
        )
    );

-- Politique pour les administrateurs - Accès complet
CREATE POLICY "Admins have full access to order items"
    ON order_items
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 
            FROM users u
            WHERE u.id = auth.uid()
            AND u."role" IN ('ADMIN', 'SUPER_ADMIN')
        )
    );

-- Trigger pour mettre à jour le champ updatedAt
CREATE OR REPLACE FUNCTION update_order_items_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW."updatedAt" = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_order_items_updated_at
    BEFORE UPDATE ON order_items
    FOR EACH ROW
    EXECUTE FUNCTION update_order_items_updated_at();

-- 6. Commentaires de la table et des colonnes pour la documentation
COMMENT ON TABLE order_items IS 'Items des commandes avec leurs quantités et prix';
COMMENT ON COLUMN order_items.id IS 'Identifiant unique de l''item';
COMMENT ON COLUMN order_items.orderId IS 'Référence à la commande parente';
COMMENT ON COLUMN order_items.articleId IS 'Référence à l''article commandé';
COMMENT ON COLUMN order_items.serviceId IS 'Référence au service appliqué';
COMMENT ON COLUMN order_items.quantity IS 'Quantité commandée';
COMMENT ON COLUMN order_items.unitPrice IS 'Prix unitaire au moment de la commande';