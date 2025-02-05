-- 1. Créer d'abord la fonction update_timestamp
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 2. Créer la table order_metadata
CREATE TABLE IF NOT EXISTS order_metadata (
    order_id UUID PRIMARY KEY REFERENCES orders(id) ON DELETE CASCADE,
    is_flash_order BOOLEAN DEFAULT false,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Créer l'index
CREATE INDEX IF NOT EXISTS idx_order_metadata_flash ON order_metadata(is_flash_order);

-- 4. Créer le trigger
DROP TRIGGER IF EXISTS update_order_metadata_timestamp ON order_metadata;
CREATE TRIGGER update_order_metadata_timestamp
    BEFORE UPDATE ON order_metadata
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();
