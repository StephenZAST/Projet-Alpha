# Référence Fonctionnelle – Système de Commandes Alpha

## 1. Vue d’ensemble
Le backend gère un système de commandes avancé pour une application de gestion de pressing/laverie, intégrant :
- Commandes multi-articles/services
- Gestion des offres, abonnements, affiliés
- Tarification flexible (par poids, premium, etc.)
- Système de fidélité et notifications

## 2. Scénarios principaux

### 2.1 Création et gestion d’une commande
- **Création** : `/api/orders` (OrderController, OrderCreateService)
  - Vérification articles/services, compatibilité, calcul du prix initial
  - Ajout d’items via `/api/order-items`
- **Modification** : PATCH `/api/orders/:orderId` ou endpoints spécifiques (adresse, statut, paiement…)
- **Suppression/Archivage** : `/api/orders/:orderId` ou `/api/archives/orders`

### 2.2 Gestion des articles et services
- **Articles** : CRUD `/api/articles`, catégories `/api/article-categories`
- **Services** : CRUD `/api/services`, types `/api/service-types`
- **Compatibilité** : `/api/service-compatibility`
- **Prix spécifiques** : `/api/article-services/prices`

### 2.3 Calcul du total d’une commande
- **Prix de base** : selon article, service, quantité, premium, poids
- **Prix par poids** : `/api/weight-pricing/calculate`
- **Services additionnels** : `/api/additional-services`

### 2.4 Application des offres et réductions
- **Offres** : `/api/offers/available`
- **Application** : automatique lors du calcul du total (DiscountService)
- **Loyauté** : points via `/api/loyalty/spend-points`

### 2.5 Gestion des affiliés
- **Affiliation** : `/api/affiliate/profile`, `/api/affiliate/commissions`
- **Commissions** : calculées lors du paiement (RewardsService)

### 2.6 Gestion des abonnements
- **Abonnés** : `/api/subscriptions/active`, `/api/subscriptions/subscribe`
- **Non-abonnés** : accès restreint à certaines offres/services

### 2.7 Commandes par poids
- **Tarification** : `/api/weight-pricing/calculate`

### 2.8 Archivage et historique
- **Archivage** : `/api/archives/orders`
- **Historique des prix** : suivi par article/service

---

## 3. Détail des scénarios et APIs

### 3.1 Création d’une commande
- **POST** `/api/orders`
- Données : `userId`, `items` (articleId, serviceId, quantité, poids, premium), `serviceTypeId`, `appliedOfferIds`
- Vérifications : disponibilité, compatibilité, application offres/points
- Réponse : JSON complet de la commande

### 3.2 Ajout/édition d’un item
- **POST** `/api/order-items` ou **PATCH** `/api/order-items/:id`
- Données : `orderId`, `articleId`, `serviceId`, `quantity`, `isPremium`, `weight`
- Vérifications : compatibilité, calcul prix

### 3.3 Calcul du total
- **POST** `/api/pricing/calculate`
- Données : `items`, `userId`, `appliedOfferIds`, `usePoints`
- Réponse : `subtotal`, `discounts`, `total`

### 3.4 Application d’une offre
- **GET** `/api/offers/available`
- Application automatique lors du calcul du total

### 3.5 Gestion des abonnements
- **GET** `/api/subscriptions/active`
- **POST** `/api/subscriptions/subscribe`
- Impact : accès à tarifs/services réservés

### 3.6 Commandes par poids
- **GET** `/api/weight-pricing/calculate`
- Utilisé pour les articles/services au kilo

### 3.7 Système d’affiliation
- **GET** `/api/affiliate/profile`, `/api/affiliate/commissions`
- Impact : commission lors du paiement

---

## 4. Scénarios d’usage (User Stories)

### 4.1 Utilisateur non abonné, sans offre
- Commande simple, total = somme des prix unitaires × quantités

### 4.2 Utilisateur abonné, avec offre
- Offre appliquée automatiquement, réduction sur le total
- Accès à services/prix réservés

### 4.3 Commande avec articles/services au poids
- Prix calculé via `/api/weight-pricing/calculate`

### 4.4 Commande affiliée
- Commission attribuée à l’affilié lors du paiement

### 4.5 Commande avec points de fidélité
- Points utilisés pour réduire le total

### 4.6 Ajout/Mise à jour en lot des items d'une commande (par article ou par poids)
```json
{
  "items": [
    { "articleId": "A1", "serviceId": "S1", "quantity": 2, "isPremium": false },
    { "articleId": "A2", "serviceId": "S1", "weight": 3.5, "isPremium": true }
  ]
}
```
  - Tous les items existants de la commande sont supprimés puis remplacés par ceux du tableau `items`.
  - Le backend recalcule automatiquement les prix (quantité ou poids, premium, etc.) pour chaque item.
  - Le total de la commande est mis à jour.
  - Compatible articles à l’unité et services au poids.
  

**Note sur les services par poids** :
Pour les types de services au poids (`WEIGHT_BASED`), il n'est pas nécessaire de sélectionner des articles : l'utilisateur saisit uniquement la valeur du poids et le service à effectuer. Le prix est calculé automatiquement selon le couple type de service/service et le prix au kilo défini dans la table `article_service_prices`. Le payload doit donc contenir le champ `weight` et le `serviceId` (et éventuellement `isPremium` si applicable), sans sélection d'article.

**Exemple pour un service au poids** :
```json
{
  "items": [
    { "serviceId": "S2", "weight": 5.0, "isPremium": false }
  ]
}
```

**Comportement** :
  - Pour les services au poids, le backend utilise le prix au kilo du couple type de service/service pour le calcul.
  - Aucun article n'est sélectionné, seule la saisie du poids est requise.
  - Le total est recalculé automatiquement.

**Remarque** : Cette distinction permet de simplifier l'UX et d'éviter toute ambiguïté lors de la gestion des commandes par poids.

---

## 5. État d’implémentation frontend

| Scénario / Feature                        | Statut Frontend | Statut Backend |
|-------------------------------------------|-----------------|---------------|
| Création/édition commande                 | En cours        | OK            |
| Ajout/édition d’item (article/service)    | En cours        | OK            |
| Calcul du total (prix, offres, points)    | À faire         | OK            |
| Gestion des abonnements                   | À faire         | OK            |
| Gestion des affiliés                      | À faire         | OK            |
| Commandes par poids                       | À faire         | OK            |
| Application automatique des offres        | À faire         | OK            |
| Archivage/historique                      | À faire         | OK            |

---

## 6. Points d’attention frontend
- Toujours utiliser les endpoints de calcul de prix
- Vérifier compatibilité article/service avant ajout
- Gérer les cas d’erreur (disponibilité, offre, etc.)
- Afficher réductions, offres, points, commissions
- Simuler tous les scénarios pour valider l’UX

---

## 7. Références techniques
- Voir les fichiers backend listés pour le détail des endpoints, schémas et règles métier
- Utiliser les routes/services correspondants pour chaque action frontend

---

> Ce document doit être mis à jour à chaque évolution majeure du backend ou du frontend.


### 2.9 Gestion avancée des prix : couple Article/Service

- Les prix des articles dépendent du service sélectionné (ex : lavage, repassage, etc.).
- La table `article_service_prices` permet de définir :
  - Un prix de base (`basePrice`)
  - Un prix premium (`premiumPrice`)
  - Un prix au kilo (`pricePerKg`) pour les services au poids
- Lors de la création ou modification d’un item de commande :
  - L’utilisateur sélectionne d’abord le service, puis l’article compatible.
  - Les prix affichés sont ceux du couple article/service.
  - Si le service est “au poids”, l’utilisateur saisit le poids total ; sinon, il saisit la quantité d’articles.

#### Exemple de workflow
1. L’admin sélectionne “Lavage au kilo” comme service.
2. Il choisit “Chemise” dans la liste des articles compatibles.
3. Le prix au kilo s’affiche (issu de `article_service_prices`).
4. L’admin saisit le poids total à traiter.
5. Le prix total est calculé automatiquement.

---

### 3.2 Ajout/édition d’un item (mise à jour)

- **POST** `/api/order-items` ou **PATCH** `/api/order-items/:id`
- Données : `orderId`, `articleId`, `serviceId`, `quantity` OU `weight`, `isPremium`
- Les prix sont récupérés via la table `article_service_prices` selon le couple sélectionné.
- Si le service est au poids, le champ `weight` est obligatoire et le prix est calculé avec `pricePerKg`.

---


---

## 8. Référence complète – Gestion des couples ServiceType / Service / Article

### 8.1 Fonctionnement général

- Un couple ServiceType/Article définit la logique de tarification et de compatibilité pour chaque commande.
- Les prix sont stockés dans `article_service_prices` : base, premium, prix au kilo (si applicable).
- Les ServiceTypes pilotent le comportement : tarification au poids (`requires_weight`), premium (`supports_premium`), abonnement (`pricing_type`), etc.
- Les Services sont liés à un ServiceType : ils héritent de ses propriétés et restrictions.
- Les Articles sont compatibles avec certains Services/ServiceTypes : la compatibilité doit être vérifiée avant ajout.

### 8.2 Bonnes pratiques d’implémentation frontend

- Toujours charger dynamiquement la liste des ServiceTypes et Services depuis l’API.
- Adapter le formulaire selon le ServiceType sélectionné :
  - Si `requires_weight` : afficher le champ poids et prix au kilo.
  - Si `supports_premium` : afficher le champ prix premium.
  - Si `pricing_type` = 'SUBSCRIPTION' : afficher les champs liés à l’abonnement.
- Vérifier la compatibilité article/service avant validation.
- Utiliser les endpoints de calcul de prix pour chaque item (jamais calculer côté frontend).
- Afficher les feedbacks utilisateur :
  - Notification si l’utilisateur tente d’activer `requires_weight` sur un type non prévu.
  - Avertir si plusieurs ServiceTypes sont marqués `is_default` (un seul doit l’être).
  - Masquer les ServiceTypes inactifs (`is_active: false`).
- Simuler tous les scénarios (poids, premium, abonnement, offres, points) pour valider l’UX.

### 8.3 Erreurs à éviter

- Ne jamais activer `requires_weight` pour un ServiceType qui ne doit pas gérer de tarification au poids.
- Ne pas avoir plusieurs ServiceTypes avec `is_default: true`.
- Ne pas ignorer le champ `is_active` lors de l’affichage (éviter de proposer des types inactifs).
- Ne pas calculer les prix côté frontend : toujours passer par l’API.
- Ne pas ignorer la compatibilité article/service : vérifier avant chaque ajout.

### 8.4 Feedback utilisateur et notifications

- Afficher une notification claire si une action interdite est tentée (ex : activer le poids sur un type non prévu).
- Avertir l’utilisateur si la configuration d’un couple est incohérente (ex : prix au kilo manquant pour un type au poids).
- Afficher les réductions, offres, points de fidélité et commissions affiliés dans le récapitulatif de commande.
- Proposer des messages d’erreur explicites en cas de problème de compatibilité ou de disponibilité.

### 8.5 Référence pour futures features

- Cette section doit servir de guide pour toute nouvelle feature liée aux couples ServiceType/Service/Article.
- Toujours se référer à la logique métier décrite ici pour garantir la cohérence et la robustesse des implémentations.

---

- **POST** `/api/pricing/calculate`
- Données : `items` (avec pour chaque item : `articleId`, `serviceId`, `quantity` OU `weight`, `isPremium`)
- Le backend utilise la table `article_service_prices` pour chaque item.