# API Documentation - Laundry Service Backend

Cette documentation détaille toutes les APIs REST disponibles dans le backend de l'application de service de blanchisserie.

## Table des matières

1. [Authentication](#authentication)
2. [Users](#users)
3. [Orders](#orders)
4. [Delivery](#delivery)
5. [Billing & Payments](#billing--payments)
6. [Analytics](#analytics)
7. [Affiliates](#affiliates)
8. [Loyalty](#loyalty)
9. [Categories](#categories)
10. [Notifications](#notifications)
11. [Admin](#admin)
12. [Zones](#zones)

---

## Authentication

### Endpoints

#### POST /api/auth/register
- Description: Inscription d'un nouvel utilisateur
- Body:
  ```json
  {
    "email": "string",
    "password": "string",
    "firstName": "string",
    "lastName": "string",
    "phone": "string"
  }
  ```
- Response (200):
  ```json
  {
    "token": "string",
    "user": {
      "id": "string",
      "email": "string",
      "firstName": "string",
      "lastName": "string",
      "role": "string"
    }
  }
  ```

#### POST /api/auth/login
- Description: Connexion utilisateur
- Body:
  ```json
  {
    "email": "string",
    "password": "string"
  }
  ```
- Response (200):
  ```json
  {
    "token": "string",
    "user": {
      "id": "string",
      "email": "string",
      "role": "string"
    }
  }
  ```

#### POST /api/auth/reset-password
- Description: Demande de réinitialisation de mot de passe
- Body:
  ```json
  {
    "email": "string"
  }
  ```
- Response (200):
  ```json
  {
    "message": "Password reset email sent"
  }
  ```

## Users

### Endpoints

#### GET /api/users/profile
- Description: Obtenir le profil de l'utilisateur connecté
- Headers: Authorization Bearer Token
- Response (200):
  ```json
  {
    "id": "string",
    "email": "string",
    "firstName": "string",
    "lastName": "string",
    "phone": "string",
    "addresses": [
      {
        "id": "string",
        "street": "string",
        "city": "string",
        "postalCode": "string",
        "isDefault": "boolean"
      }
    ]
  }
  ```

#### PUT /api/users/profile
- Description: Mettre à jour le profil utilisateur
- Headers: Authorization Bearer Token
- Body:
  ```json
  {
    "firstName": "string",
    "lastName": "string",
    "phone": "string"
  }
  ```
- Response (200):
  ```json
  {
    "message": "Profile updated successfully"
  }
  ```

## Orders

### Endpoints

#### POST /api/orders
- Description: Créer une nouvelle commande
- Headers: Authorization Bearer Token
- Body:
  ```json
  {
    "items": [
      {
        "serviceId": "string",
        "quantity": "number",
        "notes": "string"
      }
    ],
    "pickupAddress": {
      "street": "string",
      "city": "string",
      "postalCode": "string"
    },
    "deliveryAddress": {
      "street": "string",
      "city": "string",
      "postalCode": "string"
    },
    "scheduledPickup": "date-time",
    "scheduledDelivery": "date-time"
  }
  ```
- Response (201):
  ```json
  {
    "orderId": "string",
    "status": "string",
    "totalAmount": "number"
  }
  ```

#### GET /api/orders
- Description: Liste des commandes de l'utilisateur
- Headers: Authorization Bearer Token
- Query Parameters:
  - status (optional): "pending" | "processing" | "completed" | "cancelled"
  - page (optional): number
  - limit (optional): number
- Response (200):
  ```json
  {
    "orders": [
      {
        "id": "string",
        "status": "string",
        "totalAmount": "number",
        "createdAt": "date-time",
        "items": [
          {
            "service": "string",
            "quantity": "number",
            "price": "number"
          }
        ]
      }
    ],
    "totalCount": "number",
    "currentPage": "number"
  }
  ```

## Delivery

### Endpoints

#### GET /api/delivery/slots
- Description: Obtenir les créneaux de livraison disponibles
- Query Parameters:
  - date: "date"
  - zoneId: "string"
- Response (200):
  ```json
  {
    "slots": [
      {
        "id": "string",
        "startTime": "date-time",
        "endTime": "date-time",
        "available": "boolean"
      }
    ]
  }
  ```

#### POST /api/delivery/track
- Description: Suivre une livraison
- Body:
  ```json
  {
    "orderId": "string"
  }
  ```
- Response (200):
  ```json
  {
    "status": "string",
    "currentLocation": {
      "lat": "number",
      "lng": "number"
    },
    "estimatedArrival": "date-time"
  }
  ```

## Billing & Payments

### Endpoints

#### POST /api/payments/methods
- Description: Ajouter une méthode de paiement
- Headers: Authorization Bearer Token
- Body:
  ```json
  {
    "type": "CARD",
    "token": "string",
    "isDefault": "boolean"
  }
  ```
- Response (201):
  ```json
  {
    "id": "string",
    "type": "string",
    "last4": "string",
    "isDefault": "boolean"
  }
  ```

#### GET /api/billing/history
- Description: Historique des factures
- Headers: Authorization Bearer Token
- Query Parameters:
  - startDate: "date"
  - endDate: "date"
- Response (200):
  ```json
  {
    "bills": [
      {
        "id": "string",
        "orderId": "string",
        "amount": "number",
        "date": "date-time",
        "status": "string"
      }
    ]
  }
  ```

## Analytics

### Endpoints

#### GET /api/analytics/revenue
- Description: Métriques de revenus (Admin seulement)
- Headers: Authorization Bearer Token
- Query Parameters:
  - startDate: "date"
  - endDate: "date"
- Response (200):
  ```json
  {
    "totalRevenue": "number",
    "periodRevenue": "number",
    "orderCount": "number",
    "averageOrderValue": "number",
    "revenueByService": {
      "serviceName": "number"
    }
  }
  ```

#### GET /api/analytics/customers
- Description: Métriques clients (Admin seulement)
- Headers: Authorization Bearer Token
- Response (200):
  ```json
  {
    "totalCustomers": "number",
    "activeCustomers": "number",
    "customerRetentionRate": "number",
    "topCustomers": [
      {
        "userId": "string",
        "totalSpent": "number",
        "orderCount": "number"
      }
    ]
  }
  ```

## Affiliates

### Endpoints

#### POST /api/affiliates/register
- Description: Inscription d'un nouvel affilié
- Headers: Authorization Bearer Token
- Body:
  ```json
  {
    "businessName": "string",
    "website": "string",
    "taxId": "string"
  }
  ```
- Response (201):
  ```json
  {
    "affiliateId": "string",
    "referralCode": "string"
  }
  ```

#### GET /api/affiliates/earnings
- Description: Gains de l'affilié
- Headers: Authorization Bearer Token
- Query Parameters:
  - period: "monthly" | "yearly"
- Response (200):
  ```json
  {
    "totalEarnings": "number",
    "pendingPayouts": "number",
    "referrals": [
      {
        "customerId": "string",
        "orderCount": "number",
        "commission": "number"
      }
    ]
  }
  ```

## Loyalty

### Endpoints

#### GET /api/loyalty/points
- Description: Solde des points de fidélité
- Headers: Authorization Bearer Token
- Response (200):
  ```json
  {
    "points": "number",
    "tier": "string",
    "history": [
      {
        "date": "date-time",
        "points": "number",
        "description": "string"
      }
    ]
  }
  ```

#### POST /api/loyalty/redeem
- Description: Échanger des points
- Headers: Authorization Bearer Token
- Body:
  ```json
  {
    "rewardId": "string",
    "points": "number"
  }
  ```
- Response (200):
  ```json
  {
    "success": "boolean",
    "remainingPoints": "number",
    "reward": {
      "id": "string",
      "name": "string",
      "value": "number"
    }
  }
  ```

## Notifications

### Endpoints

#### GET /api/notifications
- Description: Liste des notifications
- Headers: Authorization Bearer Token
- Query Parameters:
  - unreadOnly: "boolean"
- Response (200):
  ```json
  {
    "notifications": [
      {
        "id": "string",
        "type": "string",
        "message": "string",
        "read": "boolean",
        "createdAt": "date-time"
      }
    ]
  }
  ```

#### PUT /api/notifications/:id/read
- Description: Marquer une notification comme lue
- Headers: Authorization Bearer Token
- Response (200):
  ```json
  {
    "success": "boolean"
  }
  ```

## Admin

### Endpoints

#### GET /api/admin/dashboard
- Description: Données du tableau de bord admin
- Headers: Authorization Bearer Token (Admin)
- Response (200):
  ```json
  {
    "metrics": {
      "dailyOrders": "number",
      "monthlyRevenue": "number",
      "activeCustomers": "number"
    },
    "recentOrders": [
      {
        "id": "string",
        "customer": "string",
        "amount": "number",
        "status": "string"
      }
    ]
  }
  ```

#### GET /api/admin/users
- Description: Liste des utilisateurs (Admin)
- Headers: Authorization Bearer Token (Admin)
- Query Parameters:
  - role: "customer" | "admin" | "delivery"
  - page: "number"
  - limit: "number"
- Response (200):
  ```json
  {
    "users": [
      {
        "id": "string",
        "email": "string",
        "role": "string",
        "createdAt": "date-time",
        "status": "string"
      }
    ],
    "totalCount": "number"
  }
  ```

## Zones

### Endpoints

#### GET /api/zones
- Description: Liste des zones de service
- Response (200):
  ```json
  {
    "zones": [
      {
        "id": "string",
        "name": "string",
        "coordinates": [
          {
            "lat": "number",
            "lng": "number"
          }
        ],
        "serviceAvailable": "boolean"
      }
    ]
  }
  ```

#### POST /api/zones/check
- Description: Vérifier si une adresse est dans une zone de service
- Body:
  ```json
  {
    "address": {
      "street": "string",
      "city": "string",
      "postalCode": "string"
    }
  }
  ```
- Response (200):
  ```json
  {
    "available": "boolean",
    "zone": {
      "id": "string",
      "name": "string"
    }
  }
  ```

---

## Notes générales

### Authentication
- Tous les endpoints protégés nécessitent un token Bearer dans le header Authorization
- Format: `Authorization: Bearer <token>`

### Pagination
- Les endpoints qui retournent des listes supportent la pagination
- Paramètres de pagination standards:
  - page: numéro de page (commence à 1)
  - limit: nombre d'éléments par page

### Codes d'erreur
- 400: Bad Request - Paramètres invalides
- 401: Unauthorized - Non authentifié
- 403: Forbidden - Non autorisé
- 404: Not Found - Ressource non trouvée
- 500: Internal Server Error - Erreur serveur

### Formats
- Dates: ISO 8601 (YYYY-MM-DDTHH:mm:ssZ)
- Montants: nombres décimaux (ex: 99.99)
- Coordonnées: {lat: number, lng: number}
