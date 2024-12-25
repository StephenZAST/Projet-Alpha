-- Table des offres
CREATE TABLE offers (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name varchar(255) NOT NULL,
  description text,
  discount_type varchar(20) NOT NULL, -- PERCENTAGE, FIXED_AMOUNT, POINTS_EXCHANGE
  discount_value decimal(10,2) NOT NULL,
  min_purchase_amount decimal(10,2),
  max_discount_amount decimal(10,2),
  points_required integer, -- Pour les offres échangeables contre des points
  is_cumulative boolean DEFAULT false,
  start_date timestamp with time zone,
  end_date timestamp with time zone,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Table de liaison offres-articles
CREATE TABLE offer_articles (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  offer_id uuid REFERENCES offers(id) ON DELETE CASCADE,
  article_id uuid REFERENCES articles(id) ON DELETE CASCADE,
  created_at timestamp with time zone DEFAULT now()
);

-- Table des offres utilisées par les clients
CREATE TABLE user_offers (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES users(id),
  offer_id uuid REFERENCES offers(id),
  used_at timestamp with time zone,
  order_id uuid REFERENCES orders(id),
  points_spent integer,
  created_at timestamp with time zone DEFAULT now()
);
