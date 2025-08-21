# Documentation : Système de prix lors de la création d'une commande

## Résumé
Lors de la création d'une commande, le prix réellement pris en compte pour chaque article n'est **pas** le prix de base de l'article (`basePrice` ou `premiumPrice` de la table `articles`), mais le prix du **couple** article/service/serviceType, défini dans la table `article_service_prices`.

## Fonctionnement détaillé

### 1. Construction du payload côté frontend
- Le frontend envoie pour chaque item de commande :
  - `articleId`
  - `quantity`
  - `isPremium` (optionnel)
  - `serviceTypeId`
- Le frontend affiche le prix réel du couple (issu de la table de couples) pour l'utilisateur.

### 2. Calcul du total côté backend
- Le backend utilise `PricingService.calculateOrderTotal` qui :
  - Pour chaque item, va chercher le prix du couple dans `article_service_prices` selon :
    - `articleId`
    - `serviceTypeId`
    - `isPremium` (pour choisir entre `base_price` et `premium_price`)
  - Multiplie ce prix par la quantité.
  - Additionne tous les items pour obtenir le total.

### 3. Création des order_items
- Lors de la création de la commande, chaque ligne de la table `order_items` reçoit :
  - Le prix unitaire du couple (toujours issu de `article_service_prices`)
  - Jamais le prix de la table `articles` seule.
- Si le couple n'existe pas, un fallback à 1 est appliqué (à corriger si besoin).

### 4. Pourquoi ce choix ?
- Les prix des articles varient selon le service et le type de service (ex : nettoyage à sec, repassage, etc).
- Cela permet une gestion fine des tarifs, promotions, et évolutions de prix sans toucher à la fiche article.

## Exemple
- Article : "Chemise" (basePrice = 10, premiumPrice = 15)
- Service : "Nettoyage"
- ServiceType : "Express"
- Dans `article_service_prices` :
  - `base_price` = 1200
  - `premium_price` = 1800

**=> Lors de la commande, c'est bien 1200 ou 1800 qui sera utilisé, jamais 10 ou 15.**

## Points d'attention
- Toujours vérifier que le couple existe dans `article_service_prices`.
- Si un prix n'est pas trouvé, le fallback est 1 (à personnaliser selon le besoin métier).
- Le frontend doit afficher le même prix que le backend pour éviter toute confusion utilisateur.

---
**Auteur :** GitHub Copilot
**Date :** 21/08/2025
