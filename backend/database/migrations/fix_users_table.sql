-- Supprimer la contrainte unique sur referral_code
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_referral_code_key;

-- Recréer la colonne sans la contrainte unique
ALTER TABLE users ALTER COLUMN referral_code DROP NOT NULL;
