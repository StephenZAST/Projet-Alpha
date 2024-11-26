# Subscriptions Endpoints

This document describes the API endpoints for managing subscriptions.

## Public Routes

### Get All Subscriptions

**Method:** GET
**Path:** `/subscriptions`

**Description:** Retrieves a list of all available subscriptions.

**Request Body:** None

**Response Body:**

```json
[
  {
    "id": "subscriptionId1",
    "name": "Basic Plan",
    "price": 10,
    "weightLimitPerWeek": 5,
    "description": "Basic laundry subscription",
    "features": [
      "Free pickup and delivery",
      "Standard cleaning services"
    ],
    "isActive": true
  },
  // ... more subscription entries
]
```

## User Routes

### Get User Subscription

**Method:** GET
**Path:** `/subscriptions/user/:userId`

**Description:** Retrieves the active subscription for a specific user.

**Request Body:** None

**Path Parameters:**

* `userId`: The ID of the user whose subscription to retrieve.

**Response Body:**

```json
{
  "id": "userSubscriptionId",
  "userId": "userId",
  "subscriptionId": "subscriptionId1",
  "startDate": "2023-12-19T12:00:00.000Z",
  "endDate": "2023-12-25T12:00:00.000Z",
  "status": "active"
}
```

## Admin Routes

### Create Subscription

**Method:** POST
**Path:** `/subscriptions`

**Description:** Creates a new subscription. Requires admin privileges.

**Request Body:**

```json
{
  "name": "Premium Plan",
  "price": 20,
  "weightLimitPerWeek": 10,
  "description": "Premium laundry subscription",
  "features": [
    "Free pickup and delivery",
    "Standard cleaning services",
    "Express cleaning option"
  ],
  "isActive": true
}
```

**Response Body:**

```json
{
  "id": "subscriptionId2",
  "name": "Premium Plan",
  "price": 20,
  "weightLimitPerWeek": 10,
  "description": "Premium laundry subscription",
  "features": [
    "Free pickup and delivery",
    "Standard cleaning services",
    "Express cleaning option"
  ],
  "isActive": true
}
```

### Update Subscription

**Method:** PUT
**Path:** `/subscriptions/:id`

**Description:** Updates an existing subscription by ID. Requires admin privileges.

**Request Body:**

```json
{
  "name": "Premium Plus Plan",
  "price": 30,
  "weightLimitPerWeek": 15,
  "description": "Premium Plus laundry subscription",
  "features": [
    "Free pickup and delivery",
    "Standard cleaning services",
    "Express cleaning option",
    "Dry cleaning services"
  ],
  "isActive": true
}
```

**Path Parameters:**

* `id`: The ID of the subscription to update.

**Response Body:**

```json
{
  "id": "subscriptionId2",
  "name": "Premium Plus Plan",
  "price": 30,
  "weightLimitPerWeek": 15,
  "description": "Premium Plus laundry subscription",
  "features": [
    "Free pickup and delivery",
    "Standard cleaning services",
    "Express cleaning option",
    "Dry cleaning services"
  ],
  "isActive": true
}
```

### Delete Subscription

**Method:** DELETE
**Path:** `/subscriptions/:id`

**Description:** Deletes a subscription by ID. Requires admin privileges.

**Request Body:** None

**Path Parameters:**

* `id`: The ID of the subscription to delete.

**Response Body:**

```
204 No Content
