-- 1. D'abord afficher l'article avant la mise à jour
SELECT * FROM articles 
WHERE id = 'b75ab8ac-58ef-4cdb-b57e-6c8722449cce';

-- 2. Effectuer la mise à jour directe
UPDATE articles 
SET 
    name = 'T-shirt col rond updated',
    description = 'T-shirt col rond en coton updated',
    "basePrice" = 1000,
    "premiumPrice" = 1500,
    "categoryId" = '77b9c8c1-6af6-4baf-8628-e003f5063b6c'
WHERE id = 'b75ab8ac-58ef-4cdb-b57e-6c8722449cce'
RETURNING *;

-- 3. Vérifier l'article après la mise à jour
SELECT * FROM articles 
WHERE id = 'b75ab8ac-58ef-4cdb-b57e-6c8722449cce';

-- Test de mise à jour simple
UPDATE articles 
SET name = 'Test Update'
WHERE id = 'b75ab8ac-58ef-4cdb-b57e-6c8722449cce'
RETURNING *, "updatedAt";
