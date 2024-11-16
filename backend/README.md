# Alpha Laundry Service API

## Overview
REST API for Alpha laundry service management system. A comprehensive solution for managing laundry services, including order processing, delivery management, loyalty programs, and billing.

## Features
- Complete laundry service management
- Order tracking and processing
- Delivery zone management and route optimization
- Billing and subscription management
- Loyalty program and rewards
- User role management (Super Admin, Admin, Secretary, Delivery Person)
- Analytics and reporting

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

### Role-Based Access Control
The system implements the following roles:
- SUPER_ADMIN: Full system access
- SECRETAIRE: Order and customer management
- LIVREUR: Delivery management
- SUPERVISEUR: Operations oversight
- CLIENT: Basic user access

### API Endpoints

#### Orders API

##### Create Order
```http
POST /api/orders
```
Request body:
```json
{
  "userId": "string",
  "type": "STANDARD | ONE_CLICK",
  "serviceType": "PRESSING | REPASSAGE | NETTOYAGE",
  "items": [{
    "itemType": "string",
    "quantity": "number",
    "notes": "string"
  }],
  "pickupAddress": "string",
  "deliveryAddress": "string",
  "scheduledPickupTime": "date-time",
  "scheduledDeliveryTime": "date-time"
}
```

##### Get User Orders
```http
GET /api/orders/user/{userId}
```

##### Update Order Status
```http
PUT /api/orders/{orderId}/status
```
Request body:
```json
{
  "status": "PENDING | ACCEPTED | PICKED_UP | IN_PROGRESS | READY | DELIVERING | DELIVERED"
}
```

#### Billing API

##### Create Bill
```http
POST /api/billing
```
Protected: SECRETAIRE, SUPER_ADMIN

##### Get User Bills
```http
GET /api/billing/user/{userId}
```

##### Get Billing Statistics
```http
GET /api/billing/stats
```
Protected: SUPERVISEUR, SUPER_ADMIN

#### Loyalty API

##### Get Loyalty Account
```http
GET /api/loyalty/account
```

##### Get Available Rewards
```http
GET /api/loyalty/rewards
```

##### Redeem Reward
```http
POST /api/loyalty/rewards/{rewardId}/redeem
```

#### Delivery API

##### Get Available Time Slots
```http
GET /api/delivery/timeslots
```
Query params:
- date: string
- zoneId: string

##### Schedule Pickup
```http
POST /api/delivery/schedule-pickup
```

##### Update Delivery Location
```http
POST /api/delivery/update-location
```
Protected: LIVREUR

#### Zones API

##### Create Zone
```http
POST /api/zones
```
Protected: SUPER_ADMIN

##### Get All Zones
```http
GET /api/zones
```
Protected: SUPERVISEUR, LIVREUR, SUPER_ADMIN

##### Assign Delivery Person
```http
POST /api/zones/{zoneId}/assign
```
Protected: SUPERVISEUR, SUPER_ADMIN

#### Analytics API

##### Revenue Metrics
```http
GET /api/analytics/revenue
```
Protected: SUPER_ADMIN

##### Customer Metrics
```http
GET /api/analytics/customers
```
Protected: SUPER_ADMIN

### Models

#### Order Status Flow
```
PENDING → ACCEPTED → PICKED_UP → IN_PROGRESS → READY → DELIVERING → DELIVERED
```

#### Loyalty Tiers
- BRONZE: 0-1000 points
- SILVER: 1001-5000 points
- GOLD: 5001-10000 points
- PLATINUM: 10001+ points

### Error Handling
Standardized error responses:
```json
{
  "status": "error",
  "code": "ERROR_CODE",
  "message": "Error description"
}
```

Common error codes:
- INVALID_ORDER_DATA
- SLOT_NOT_AVAILABLE
- INVALID_PRICE_RANGE
- ZONE_HAS_ACTIVE_ORDERS
- ONE_CLICK_ORDER_FAILED

### Price Ranges
- Standard Wash & Iron: 500-50000 XOF
- Basic Wash & Iron: 300-30000 XOF
- Dry Cleaning: 200-75000 XOF
- Ironing Only: 50-25000 XOF

### Environment Variables
```
PORT=3001
ALLOWED_ORIGINS=http://localhost:3000
FIREBASE_PROJECT_ID=alpha-79c09
```

### Tech Stack
- Node.js + Express
- TypeScript
- Firebase Admin SDK
- Joi Validation
- Firebase/Firestore Database

### Security Features
- Role-based access control
- JWT Authentication
- Request rate limiting
- Input validation
- Error sanitization

### Best Practices
- Comprehensive error handling
- Type safety with TypeScript
- Modular architecture
- Clean code principles
- Detailed logging

## Contributing
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License
ISC
