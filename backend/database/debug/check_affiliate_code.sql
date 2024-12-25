
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'affiliate_profiles';

SELECT affiliate_code, user_id 
FROM affiliate_profiles 
WHERE affiliate_code = 'Y7VSRJ2YV';