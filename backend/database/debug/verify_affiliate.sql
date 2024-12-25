-- Vérifier avec insensibilité à la casse
SELECT * FROM affiliate_profiles 
WHERE affiliate_code ILIKE $1;
