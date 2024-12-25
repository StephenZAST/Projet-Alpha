-- Create notification preferences table
CREATE TABLE notification_preferences (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid REFERENCES users(id) NOT NULL UNIQUE,
  email boolean DEFAULT true,
  push boolean DEFAULT true,
  sms boolean DEFAULT false,
  order_updates boolean DEFAULT true,
  promotions boolean DEFAULT true,
  payments boolean DEFAULT true,
  loyalty boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Create index for faster lookups
CREATE INDEX idx_notification_preferences_user_id ON notification_preferences(user_id);
