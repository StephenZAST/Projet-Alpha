-- Politiques pour la table order_items
CREATE POLICY "Les utilisateurs peuvent voir leurs propres items de commande"
ON order_items
FOR SELECT
USING (
  orderId IN (
    SELECT id FROM orders WHERE userId = auth.uid()
  )
);

CREATE POLICY "Les admins peuvent voir tous les items de commande"
ON order_items
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role IN ('ADMIN', 'SUPER_ADMIN')
  )
);

CREATE POLICY "Les utilisateurs peuvent créer des items pour leurs commandes"
ON order_items
FOR INSERT
WITH CHECK (
  orderId IN (
    SELECT id FROM orders WHERE userId = auth.uid()
  )
);

CREATE POLICY "Les admins peuvent créer des items pour toutes les commandes"
ON order_items
FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.role IN ('ADMIN', 'SUPER_ADMIN')
  )
);

-- Activer RLS sur la table order_items
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Politiques pour la table articles
CREATE POLICY "Tout le monde peut voir les articles"
ON articles
FOR SELECT
USING (true);

-- Activer RLS sur la table articles
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;

-- Politiques pour la table article_categories
CREATE POLICY "Tout le monde peut voir les catégories d'articles"
ON article_categories
FOR SELECT
USING (true);

-- Activer RLS sur la table article_categories
ALTER TABLE article_categories ENABLE ROW LEVEL SECURITY;