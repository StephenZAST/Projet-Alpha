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
