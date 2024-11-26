# Billing Endpoints

This document describes the API endpoints for managing bills, invoices, loyalty points, subscriptions, and special offers.

## Authenticated Routes

### Get Bill by ID

**Method:** GET
**Path:** `/billing/{billId}`

**Description:** Retrieves a specific bill by its ID.

**Request Body:** None

**Path Parameters:**

* `billId`: The ID of the bill to retrieve.

**Response Body:**

```json
{
  "bill": {
    "orderId": "orderId",
    "items": [
      {
        "name": "Item 1",
        "quantity": 2,
        "price": 10
      },
      // ... more items
    ],
    "totalAmount": 100,
    // ... other bill fields
  }
}
```

### Get Bills for User

**Method:** GET
**Path:** `/billing/user/{userId}`

**Description:** Retrieves all bills for a specific user.

**Request Body:** None

**Path Parameters:**

* `userId`: The ID of the user whose bills to retrieve.

**Response Body:**

```json
{
  "bills": [
    {
      "orderId": "orderId",
      "items": [
        {
          "name": "Item 1",
          "quantity": 2,
          "price": 10
        },
        // ... more items
      ],
      "totalAmount": 100,
      // ... other bill fields
    },
    // ... more bill entries
  ]
}
```

### Get User's Loyalty Points

**Method:** GET
**Path:** `/billing/loyalty/{userId}`

**Description:** Retrieves a user's loyalty points, history, and available rewards.

**Request Body:** None

**Path Parameters:**

* `userId`: The ID of the user whose loyalty points to retrieve.

**Response Body:**

```json
{
  "loyaltyPoints": 100,
  "history": [
    {
      "date": "2023-12-19",
      "points": 50
    },
    // ... more history entries
  ],
  "availableRewards": [
    {
      "name": "Reward 1",
      "points": 50
    },
    // ... more reward entries
  ]
}
```

### Redeem Loyalty Points

**Method:** POST
**Path:** `/billing/loyalty/redeem`

**Description:** Redeems loyalty points for a reward.

**Request Body:**

```json
{
  "rewardId": "rewardId",
  "points": 50
}
```

**Response Body:**

```json
{
  "message": "Points redeemed successfully",
  "remainingPoints": 50,
  "reward": {
    "name": "Reward 1",
    "points": 50
  }
}
```

### Update Subscription

**Method:** POST
**Path:** `/billing/subscription`

**Description:** Updates a user's subscription.

**Request Body:**

```json
{
  "subscriptionType": "monthly",
  "paymentMethod": "credit card"
}
```

**Response Body:**

```json
{
  "message": "Subscription updated successfully",
  "subscription": {
    "type": "monthly",
    "paymentMethod": "credit card"
  }
}
```

## Admin-Only Routes

### Create Bill

**Method:** POST
**Path:** `/billing`

**Description:** Creates a new bill.

**Request Body:**

```json
{
  "orderId": "orderId",
  "items": [
    {
      "name": "Item 1",
      "quantity": 2,
      "price": 10
    },
    // ... more items
  ],
  "totalAmount": 100
}
```

**Response Body:**

```json
{
  "message": "Bill created successfully"
}
```

### Get Billing Statistics

**Method:** GET
**Path:** `/billing/stats`

**Description:** Retrieves billing statistics for a specified date range.

**Request Body:** None

**Query Parameters:**

* `startDate`: Start date for statistics (YYYY-MM-DD).
* `endDate`: End date for statistics (YYYY-MM-DD).

**Response Body:**

```json
{
  "stats": {
    "totalRevenue": 10000,
    "totalOrders": 100,
    "averageOrderValue": 100,
    "subscriptionRevenue": 2000,
    "loyaltyPointsIssued": 5000,
    "loyaltyPointsRedeemed": 1000
  }
}
```

### Create Special Offer

**Method:** POST
**Path:** `/billing/offers`

**Description:** Creates a special offer.

**Request Body:**

```json
{
  "name": "Offer Name",
  "description": "Offer Description",
  "discountType": "percentage",
  "discountValue": 10,
  "startDate": "2023-12-20",
  "endDate": "2023-12-25"
}
```

**Response Body:**

```json
{
  "message": "Special offer created successfully",
  "offer": {
    "name": "Offer Name",
    "description": "Offer Description",
    "discountType": "percentage",
    "discountValue": 10,
    "startDate": "2023-12-20",
    "endDate": "2023-12-25"
  }
}
