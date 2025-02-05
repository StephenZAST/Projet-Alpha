-- Créer une table pour les métadonnées des commandes
CREATE TABLE order_metadata (
    order_id UUID PRIMARY KEY REFERENCES orders(id) ON DELETE CASCADE,
    is_flash_order BOOLEAN DEFAULT false,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index pour optimiser les requêtes
CREATE INDEX idx_order_metadata_flash ON order_metadata(is_flash_order);

-- Trigger pour mettre à jour updated_at
CREATE TRIGGER update_order_metadata_timestamp
    BEFORE UPDATE ON order_metadata
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();
