# Charte API Laverie - Documentation Simplifiée

## 1. Structure du Projet
backend/
├── src/
├── config/ # Configuration DB, env
├── controllers/ # Logique métier
├── models/ # Modèles de données
├── routes/ # Routes API
├── services/ # Services partagés
└── app.ts # Point d'entrée



## 2. Modèles de Données

### Utilisateur (Profile)
- id: UUID
- email: string
- nom: string
- prénom: string
- téléphone: string
- rôle: enum [CLIENT, ADMIN, DELIVERY]

### Commande (Order)
- id: UUID
- userId: UUID
- serviceId: UUID
- addressId: UUID
- quantité: number
- statut: enum [EN_ATTENTE, EN_COURS, TERMINÉ]
- montantTotal: decimal

### Service
- id: UUID
- nom: string
- prix: decimal

### Adresse
- id: UUID
- userId: UUID
- adresse: string
- ville: string

## 3. Routes API

### Auth (/api/auth)
- POST /register
- POST /login

### Utilisateurs (/api/users)
- GET /profile
- PUT /profile

### Commandes (/api/orders)
- POST /
- GET /
- GET /:id
- PUT /:id/status

### Services (/api/services)
- GET /
- GET /:id

## 4. Règles Métier Simples

### Commandes
- Client peut créer une commande
- Admin peut voir toutes les commandes
- Delivery peut voir/modifier ses commandes assignées
- Statut mis à jour automatiquement

### Validation
- Email valide requis
- Mot de passe 6+ caractères
- Adresse obligatoire pour commande
- Quantité > 0

## 5. Sécurité Basique
- JWT Authentication
- Routes protégées par rôle
- Validation des entrées
- Rate limiting: 100 requêtes/10min

## 6. Variables d'Environnement
DATABASE_URL=
JWT_SECRET=
PORT=
NODE_ENV=
CORS_ORIGIN=




## 7. Codes d'Erreur
- 400: Requête invalide
- 401: Non authentifié
- 403: Non autorisé
- 404: Ressource non trouvée
- 500: Erreur serveur