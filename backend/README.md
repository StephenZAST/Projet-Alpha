# Alpha Laundry Service API

## Overview
REST API for Alpha laundry service management system, handling articles, orders, subscriptions, and user management.

## Setup Instructions

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables:
```bash
cp .env.example .env
```

3. Start the server:
```bash
npm run dev
```

## API Documentation

### Authentication
All protected routes require Bearer token authentication:

```
Authorization: Bearer <token>
```

### Articles API

#### Get All Articles
```
GET /api/articles
```
Public endpoint to retrieve all available articles.

#### Create Article (Admin only)
```
POST /api/articles
```
Request body:

```json
{
  "articleName": "Chemise",
  "articleCategory": "Chemisier",
  "prices": {
    "wash_and_iron": {
      "STANDARD": 500,
      "BASIC": 300
    }
  },
  "availableServices": ["wash_and_iron"],
  "availableAdditionalServices": []
}
```

#### Update Article (Admin only)
```
PUT /api/articles/:id
```

#### Delete Article (Admin only)
```
DELETE /api/articles/:id
```

### Subscriptions API

#### Get All Subscriptions
```
GET /api/subscriptions
```

#### Create Subscription (Admin only)
```
POST /api/subscriptions
```
Request body:

```json
{
  "name": "Premium",
  "price": 30000,
  "weightLimitPerWeek": 20,
  "description": "Premium subscription with 20kg weekly limit"
}
```

### Orders API

#### Create Order
```
POST /api/orders
```
Request body:

```json
{
  "items": [],
  "pickup": {
    "address": {},
    "scheduledDate": "2024-01-20",
    "timeSlot": {}
  }
}
```

### Service Documentation

* **Article Service:** Located in `src/services/articles.ts`
    * `createArticle`: Creates new article with pricing and services
    * `getArticles`: Retrieves all articles
    * `updateArticle`: Updates existing article
    * `deleteArticle`: Removes article from system

* **Subscription Service:** Located in `src/services/subscriptions.ts`
    * `createSubscription`: Creates new subscription plan
    * `getSubscriptions`: Retrieves all subscription plans
    * `getUserSubscription`: Gets active subscription for specific user

* **Order Service:** Located in `src/services/orders.ts`
    * `createOrder`: Creates new laundry order
    * `getOrdersByUser`: Retrieves user's order history
    * `updateOrderStatus`: Updates order processing status

### Error Handling
The API uses standardized error responses:

```json
{
  "status": "error",
  "code": "ERROR_CODE",
  "message": "Error description"
}
```

### Price Ranges
Standard Wash & Iron: 500-50000 XOF
Basic Wash & Iron: 300-30000 XOF
Dry Cleaning: 200-75000 XOF
Ironing Only: 50-25000 XOF

### Environment Variables
```
PORT=3001
ALLOWED_ORIGINS=http://localhost:3000
FIREBASE_PROJECT_ID=alpha-79c09
```

### Tech Stack
Node.js + Express
TypeScript
Firebase Admin SDK
Joi Validation
