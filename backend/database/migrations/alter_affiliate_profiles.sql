-- Ajout des nouvelles colonnes pour améliorer la gestion des affiliés
ALTER TABLE affiliate_profiles 
  ADD COLUMN commission_rate decimal(5,2) DEFAULT 10.00,
  ADD COLUMN status varchar(20) DEFAULT 'PENDING',
  ADD COLUMN is_active boolean DEFAULT true,
  ADD COLUMN total_referrals integer DEFAULT 0,
  ADD COLUMN monthly_earnings decimal(10,2) DEFAULT 0.00;

-- Créer une table pour les niveaux d'affiliation
CREATE TABLE affiliate_levels (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name varchar(50) NOT NULL,
  min_earnings decimal(10,2) NOT NULL,
  commission_rate decimal(5,2) NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);

-- Ajouter une référence au niveau dans affiliate_profiles
ALTER TABLE affiliate_profiles
  ADD COLUMN level_id uuid REFERENCES affiliate_levels(id);

-- Insérer les niveaux par défaut
INSERT INTO affiliate_levels (name, min_earnings, commission_rate) VALUES
  ('Bronze', 0, 5.00),
  ('Silver', 1000, 7.50),
  ('Gold', 5000, 10.00),
  ('Platinum', 10000, 12.50);
