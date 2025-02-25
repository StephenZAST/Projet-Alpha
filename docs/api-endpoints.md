# API Endpoints Documentation 

## 💫 Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Créer un nouveau compte utilisateur |
| POST | `/api/auth/login` | Se connecter |
| POST | `/api/auth/logout` | Se déconnecter |
| POST | `/api/auth/reset-password` | Demander un reset de mot de passe |
| POST | `/api/auth/verify-reset-code` | Vérifier le code de reset |
| POST | `/api/auth/change-password` | Changer le mot de passe |

## 👤 Users 
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/users/profile` | Obtenir le profil utilisateur |
| PUT | `/api/users/profile` | Mettre à jour le profil |
| GET | `/api/users/notifications` | Obtenir les notifications |
| PUT | `/api/users/notifications/preferences` | Mettre à jour les préférences de notification |

## 🛍️ Orders
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/orders` | Créer une nouvelle commande |
| GET | `/api/orders` | Liste des commandes de l'utilisateur |
| GET | `/api/orders/:id` | Détails d'une commande |
| POST | `/api/orders/flash` | Créer une commande flash |
| PATCH | `/api/orders/:id/status` | Mettre à jour le statut |
| GET | `/api/orders/:id/items` | Articles d'une commande |

## 📦 Articles
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/articles` | Liste des articles |
| GET | `/api/articles/:id` | Détails d'un article |
| GET | `/api/articles/:id/services` | Services disponibles pour un article |
| POST | `/api/admin/articles` | [Admin] Créer un article |
| PUT | `/api/admin/articles/:id` | [Admin] Modifier un article |
| DELETE | `/api/admin/articles/:id` | [Admin] Supprimer un article |

## 🏷️ Offers & Discounts
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/offers/available` | Offres disponibles |
| POST | `/api/offers/:id/subscribe` | Souscrire à une offre |
| GET | `/api/offers/my-subscriptions` | Mes souscriptions |
| POST | `/api/admin/offers` | [Admin] Créer une offre |
| PUT | `/api/admin/offers/:id` | [Admin] Modifier une offre |
| DELETE | `/api/admin/offers/:id` | [Admin] Supprimer une offre |

## 🤝 Affiliate System
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/affiliate/register` | Devenir affilié |
| GET | `/api/affiliate/profile` | Profil d'affilié |
| GET | `/api/affiliate/commissions` | Historique des commissions |
| POST | `/api/affiliate/withdraw` | Demande de retrait |
| GET | `/api/admin/affiliates` | [Admin] Liste des affiliés |
| PUT | `/api/admin/affiliates/:id/status` | [Admin] Modifier statut affilié |

## 💎 Loyalty
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/loyalty/points` | Solde des points |
| GET | `/api/loyalty/history` | Historique des points |
| POST | `/api/loyalty/redeem` | Utiliser des points |

## 🔔 Notifications
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/notifications` | Liste des notifications |
| PUT | `/api/notifications/:id/read` | Marquer comme lu |
| PUT | `/api/notifications/read-all` | Tout marquer comme lu |

## 🚚 Delivery
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/delivery/orders/pending` | Commandes en attente |
| GET | `/api/delivery/orders/assigned` | Commandes assignées |
| PATCH | `/api/delivery/orders/:id/status` | Mettre à jour statut livraison |

## 📊 Admin Dashboard
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/admin/stats/overview` | Statistiques générales |
| GET | `/api/admin/stats/revenue` | Statistiques revenus |
| GET | `/api/admin/stats/orders` | Statistiques commandes |
| GET | `/api/admin/withdrawals` | Demandes de retrait |
| PATCH | `/api/admin/withdrawals/:id/approve` | Approuver retrait |
| PATCH | `/api/admin/withdrawals/:id/reject` | Rejeter retrait |

## 💰 Pricing
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/pricing/calculate` | Calculer prix commande |
| GET | `/api/pricing/service/:id` | Prix par service |
| PUT | `/api/admin/pricing/update` | [Admin] Mettre à jour prix |

## 🗂️ Services et Catégories
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/services` | Liste des services disponibles |
| GET | `/api/services/:id` | Détails d'un service |
| GET | `/api/services/:id/prices` | Prix d'un service |
| GET | `/api/service-types` | Liste des types de services |
| GET | `/api/categories` | Liste des catégories d'articles |
| GET | `/api/categories/:id/articles` | Articles d'une catégorie |

## 📝 Blog
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/blog/articles` | Liste des articles de blog |
| GET | `/api/blog/articles/:id` | Détails d'un article |
| POST | `/api/admin/blog/articles` | [Admin] Créer un article |
| PUT | `/api/admin/blog/articles/:id` | [Admin] Modifier un article |
| DELETE | `/api/admin/blog/articles/:id` | [Admin] Supprimer un article |

## 📊 Prix et Compatibilité
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/compatibility/check` | Vérifier compatibilité article/service |
| GET | `/api/price-by-weight` | Calculer prix au poids |
| POST | `/api/admin/compatibility` | [Admin] Définir compatibilité |
| POST | `/api/admin/weight-pricing` | [Admin] Définir prix au poids |

## 📦 Flash Orders
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/orders/flash/create` | Créer commande flash |
| PUT | `/api/orders/flash/:id/complete` | Compléter commande flash |
| GET | `/api/orders/flash/pending` | Liste commandes flash en attente |

## 🚛 Delivery Zones
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/delivery/zones` | Liste des zones de livraison |
| POST | `/api/admin/delivery/zones` | [Admin] Créer zone |
| PUT | `/api/admin/delivery/zones/:id` | [Admin] Modifier zone |
| GET | `/api/delivery/check-availability` | Vérifier disponibilité livraison |

## Notes d'implémentation

### Authentification
- Tous les endpoints (sauf login/register) nécessitent un JWT token valide
- Format du token: `Bearer <token>`
- Le token expire après 7 jours

### Pagination
Les endpoints listant plusieurs éléments supportent la pagination avec les paramètres:
- `page`: Numéro de page (défaut: 1)
- `limit`: Nombre d'éléments par page (défaut: 10, max: 100)

### Filtres & Tri
Certains endpoints supportent des paramètres de filtrage/tri:
- `sort`: Champ de tri
- `order`: Ordre de tri (asc/desc) 
- `status`: Filtrer par statut
- `search`: Recherche textuelle

### Réponses
Format standard des réponses:
