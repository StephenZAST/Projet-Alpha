# Recurring Orders Endpoints

This document describes the API endpoints for managing recurring orders.

## Authenticated Routes

### Create a New Recurring Order

**Method:** POST
**Path:** `/recurringOrders`

**Description:** Creates a new recurring order for the authenticated user.

**Request Body:**

```json
{
  "frequency": "WEEKLY",
  "baseOrder": {
    "items": [
      {
        // ... item details
      }
    ],
    "address": {
      // ... address details
    },
    "preferences": {
      // ... preferences details
    }
  }
}
```

**Response Body:**

```json
{
  "message": "Recurring order created successfully",
  "recurringOrder": {
    // ... recurring order details
  }
}
```

### Update a Recurring Order

**Method:** PUT
**Path:** `/recurringOrders/{id}`

**Description:** Updates an existing recurring order by ID for the authenticated user.

**Request Body:**

```json
{
  "frequency": "MONTHLY",
  "baseOrder": {
    // ... updated base order details
  },
  "isActive": false
}
```

**Path Parameters:**

* `id`: The ID of the recurring order to update.

**Response Body:**

```json
{
  "message": "Recurring order updated successfully",
  "recurringOrder": {
    // ... updated recurring order details
  }
}
```

### Cancel a Recurring Order

**Method:** POST
**Path:** `/recurringOrders/{id}/cancel`

**Description:** Cancels an existing recurring order by ID for the authenticated user.

**Request Body:** None

**Path Parameters:**

* `id`: The ID of the recurring order to cancel.

**Response Body:**

```json
{
  "message": "Recurring order cancelled successfully"
}
```

### Get All Active Recurring Orders

**Method:** GET
**Path:** `/recurringOrders`

**Description:** Retrieves all active recurring orders for the authenticated user.

**Request Body:** None

**Response Body:**

```json
{
  "recurringOrders": [
    {
      // ... recurring order details
    },
    // ... more recurring order entries
  ]
}
```

## Admin-Only Routes

### Process Pending Recurring Orders

**Method:** POST
**Path:** `/recurringOrders/process`

**Description:** Processes all pending recurring orders. This endpoint is protected and can only be accessed by admin users.

**Request Body:** None

**Response Body:**

```json
{
  "message": "Recurring orders processed successfully"
}
