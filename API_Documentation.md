# Documentation API Alpha Laundry Management System

Cette documentation détaille tous les endpoints API REST disponibles dans le système, organisés par type d'utilisateur et contexte.

## Table des Matières

1. [Authentication](#authentication)
2. [Master Super Admin API](#master-super-admin-api)
3. [Super Admin API](#super-admin-api)
4. [Admin API](#admin-api)
5. [Affiliate API](#affiliate-api)
6. [Customer API](#customer-api)

## Guide d'Utilisation Rapide

### Base URL
```
https://api.alpha-laundry.com/v1
```

### Authentication
Tous les endpoints (sauf login) nécessitent un token JWT dans le header :
```
Authorization: Bearer <votre_token_jwt>
```

### Format des Réponses
Toutes les réponses suivent ce format :
```json
{
    "success": boolean,
    "message": string,
    "data": any
}
```

## Authentication

### Login
```http
POST /auth/login
```

**Body:**
```json
{
    "email": "string",
    "password": "string"
}
```

**Response:**
```json
{
    "success": true,
    "message": "Login successful",
    "data": {
        "token": "string",
        "user": {
            "id": "string",
            "email": "string",
            "role": "string",
            "permissions": ["string"]
        }
    }
}
```

## Master Super Admin API

### Gestion des Administrateurs

#### Lister tous les administrateurs
```http
GET /admin/list
```

#### Créer un administrateur
```http
POST /admin/create
```

**Body:**
```json
{
    "email": "string",
    "password": "string",
    "role": "string",
    "permissions": ["string"]
}
```

#### Modifier un administrateur
```http
PUT /admin/:id
```

#### Supprimer un administrateur
```http
DELETE /admin/:id
```

### Gestion des Affiliés

#### Lister tous les affiliés
```http
GET /affiliate/list
```

#### Créer un affilié
```http
POST /affiliate/create
```

**Body:**
```json
{
    "name": "string",
    "email": "string",
    "address": {
        "street": "string",
        "city": "string",
        "country": "string"
    },
    "contact": {
        "phone": "string",
        "email": "string"
    }
}
```

## Super Admin API

### Gestion des Commandes

#### Lister les commandes
```http
GET /orders
```

Paramètres de requête :
- `status`: Filtrer par statut
- `date`: Filtrer par date
- `page`: Numéro de page
- `limit`: Nombre d'éléments par page

#### Créer une commande
```http
POST /orders
```

**Body:**
```json
{
    "customerId": "string",
    "items": [
        {
            "serviceId": "string",
            "quantity": number
        }
    ],
    "pickupDate": "string",
    "deliveryDate": "string"
}
```

### Gestion des Services

#### Lister les services
```http
GET /services
```

#### Ajouter un service
```http
POST /services
```

## Admin API

### Gestion des Clients

#### Lister les clients
```http
GET /customers
```

#### Ajouter un client
```http
POST /customers
```

## Affiliate API

### Gestion des Ressources

#### Voir les ressources disponibles
```http
GET /resources
```

#### Mettre à jour une ressource
```http
PUT /resources/:id
```

### Gestion des Services

#### Voir les services disponibles
```http
GET /services
```

#### Mettre à jour un service
```http
PUT /services/:id
```

## Customer API

### Commandes

#### Voir mes commandes
```http
GET /orders/my
```

#### Créer une nouvelle commande
```http
POST /orders
```

## Gestion des Erreurs

### Codes d'erreur HTTP

- 400: Bad Request - La requête est mal formée
- 401: Unauthorized - Authentication requise
- 403: Forbidden - Permissions insuffisantes
- 404: Not Found - Ressource non trouvée
- 500: Internal Server Error - Erreur serveur

### Format des erreurs
```json
{
    "success": false,
    "message": "Description de l'erreur",
    "error": {
        "code": "ERROR_CODE",
        "details": {}
    }
}
```

## Bonnes Pratiques

1. **Rate Limiting**
- Maximum 100 requêtes par minute par IP
- Maximum 1000 requêtes par heure par token

2. **Caching**
- Les réponses incluent des headers de cache appropriés
- Utilisez les ETags pour optimiser les requêtes

3. **Sécurité**
- Toutes les requêtes doivent être en HTTPS
- Les tokens JWT expirent après 24 heures
- Utilisation de CORS pour la sécurité

## Webhooks

### Événements disponibles

1. **Commande**
- `order.created`
- `order.updated`
- `order.completed`

2. **Client**
- `customer.created`
- `customer.updated`

### Format des webhooks
```json
{
    "event": "string",
    "timestamp": "string",
    "data": {}
}
```
