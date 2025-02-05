CREATE OR REPLACE FUNCTION sync_order_note()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        -- Mettre à jour les métadonnées quand une note est modifiée
        UPDATE order_metadata
        SET metadata = jsonb_set(
            metadata,
            '{note}',
            to_jsonb(NEW.note)
        )
        WHERE order_id = NEW.order_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER order_note_sync_trigger
AFTER INSERT OR UPDATE ON order_notes
FOR EACH ROW
EXECUTE FUNCTION sync_order_note();
