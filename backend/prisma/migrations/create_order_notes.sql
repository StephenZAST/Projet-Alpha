-- Création de la table pour les notes de commandes
CREATE TABLE order_notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    note TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Création d'une fonction pour insérer une note de commande flash
CREATE OR REPLACE FUNCTION insert_flash_order_note()
RETURNS TRIGGER AS $$
BEGIN
    -- Insertion de la note uniquement si c'est une commande flash (status = DRAFT)
    IF NEW.status = 'DRAFT' AND TG_OP = 'INSERT' THEN
        INSERT INTO order_notes (order_id, note)
        VALUES (NEW.id, TG_ARGV[0]); -- La note sera passée comme argument du trigger
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Création du trigger qui s'active à l'insertion d'une commande flash
CREATE TRIGGER flash_order_note_trigger
AFTER INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION insert_flash_order_note();

-- Index pour les recherches rapides par order_id
CREATE INDEX idx_order_notes_order_id ON order_notes(order_id);

-- Commentaires
COMMENT ON TABLE order_notes IS 'Notes associées aux commandes flash';
COMMENT ON COLUMN order_notes.order_id IS 'ID de la commande associée';
COMMENT ON COLUMN order_notes.note IS 'Contenu de la note';