# Alpha Laundry Service API

## Overview
A comprehensive REST API for Alpha laundry service management system. This system provides end-to-end solutions for laundry service operations, including order management, delivery optimization, affiliate programs, loyalty rewards, and real-time tracking.

## Core Features
- Complete Laundry Service Management
- Advanced Order Processing & Tracking
- Intelligent Delivery Management with Route Optimization
- Billing and Subscription System
- Affiliate Program Management
- Loyalty Program and Rewards
- Analytics and Reporting
- Multi-Role User Management
- Real-time Location Tracking
- Zone-based Service Management

## Technical Stack
- **Runtime**: Node.js with Express
- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth
- **Real-time Updates**: WebSocket
- **Geolocation**: Custom geohashing implementation
- **Caching**: In-memory caching with TTL support
- **Documentation**: OpenAPI/Swagger

## Setup Instructions

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables:
```bash
cp .env.example .env
```

3. Start the development server:
```bash
npm run dev
```

4. Access the Swagger documentation:
```
http://localhost:3000/api-docs
```

## Core Modules

### 1. Authentication & Authorization
- JWT-based authentication
- Role-based access control (RBAC)
- Permission management
- Session handling

### 2. Order Management
- Order creation and tracking
- Service type categorization
- Status updates
- Price calculation
- Scheduling

### 3. Delivery System
- Real-time location tracking
- Route optimization
- Geofencing
- Zone management
- Task assignment

### 4. Affiliate System
- Affiliate registration
- Commission tracking
- Performance analytics
- Payment management

### 5. Loyalty Program
- Point accumulation
- Reward redemption
- Tier management
- Special offers

### 6. Analytics
- Business metrics
- Performance tracking
- Customer insights
- Operational statistics

## API Structure

### Authentication
All protected routes require Bearer token authentication:
```
Authorization: Bearer <token>
```

### Role-Based Access Control
- SUPER_ADMIN: Full system access
- ADMIN: System management
- SECRETAIRE: Order and customer management
- LIVREUR: Delivery operations
- SUPERVISEUR: Operations oversight
- AFFILIATE: Affiliate portal access
- CLIENT: Customer features

## Available Endpoints

### Authentication Routes
- POST /api/auth/register
- POST /api/auth/login
- POST /api/auth/refresh-token
- POST /api/auth/forgot-password
- POST /api/auth/reset-password

### User Management
- GET /api/users
- GET /api/users/:id
- PUT /api/users/:id
- DELETE /api/users/:id

### Order Management
- POST /api/orders
- GET /api/orders
- GET /api/orders/:id
- PUT /api/orders/:id
- GET /api/orders/user/:userId
- PUT /api/orders/:id/status

### Delivery Management
- GET /api/delivery/tasks
- POST /api/delivery/tasks
- PUT /api/delivery/tasks/:id
- GET /api/delivery/zones
- POST /api/delivery/location
- GET /api/delivery/optimize-route

### Affiliate System
- POST /api/affiliate/register
- GET /api/affiliate/dashboard
- GET /api/affiliate/commissions
- POST /api/affiliate/withdraw
- GET /api/affiliate/performance

### Loyalty Program
- GET /api/loyalty/points
- POST /api/loyalty/redeem
- GET /api/loyalty/history
- GET /api/loyalty/offers

### Billing & Subscriptions
- POST /api/billing/invoice
- GET /api/billing/history
- POST /api/subscriptions
- GET /api/subscriptions/active

### Analytics
- GET /api/analytics/overview
- GET /api/analytics/sales
- GET /api/analytics/performance
- GET /api/analytics/customer-insights

## WebSocket Events

### Driver Location Updates
```javascript
// Connect to WebSocket
const ws = new WebSocket('ws://localhost:3000/ws?token=<auth_token>');

// Location update event
ws.send(JSON.stringify({
  type: 'location',
  payload: {
    latitude: number,
    longitude: number
  }
}));
```

### Real-time Notifications
```javascript
// Listen for updates
ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  switch(data.type) {
    case 'task':
      // New delivery task
      break;
    case 'geofence':
      // Zone entry/exit event
      break;
  }
};
```

## Error Handling
The API uses standard HTTP status codes and returns errors in the following format:
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message",
    "details": {}
  }
}
```

## Rate Limiting
- API requests are limited to 100 requests per minute per IP
- WebSocket connections are limited to 1 per authenticated user

## Caching
- Geolocation data: 5 minutes TTL
- Route calculations: 5 minutes TTL
- User data: 15 minutes TTL
- Zone data: 1 hour TTL

## Contributing
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License
This project is proprietary and confidential. Unauthorized copying or distribution is prohibited.
