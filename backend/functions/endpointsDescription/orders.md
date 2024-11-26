# Orders Endpoints

This document describes the API endpoints for managing orders.

## Public Routes

### Get All Orders

**Method:** GET
**Path:** `/orders`

**Description:** Retrieves a list of all orders.

**Request Body:** None

**Response Body:**

```json
[
  {
    "id": "orderId1",
    "customerId": "customerId1",
    "orderDate": "2023-12-19T12:00:00.000Z",
    "totalAmount": 100,
    "status": "PENDING"
  },
  // ... more orders
]
```

## Authenticated Routes

### Create Order

**Method:** POST
**Path:** `/orders`

**Description:** Creates a new order.

**Request Body:**

```json
{
  "customerId": "customerId2",
  "orderDate": "2023-12-20T12:00:00.000Z",
  "totalAmount": 200,
  "status": "PENDING"
}
```

**Response Body:**

```json
{
  "id": "orderId2",
  "customerId": "customerId2",
  "orderDate": "2023-12-20T12:00:00.000Z",
  "totalAmount": 200,
  "status": "PENDING"
}
```

### Update Order

**Method:** PUT
**Path:** `/orders/{id}`

**Description:** Updates an existing order by ID.

**Request Body:**

```json
{
  "customerId": "customerId3",
  "orderDate": "2023-12-21T12:00:00.000Z",
  "totalAmount": 250,
  "status": "SHIPPED"
}
```

**Path Parameters:**

* `id`: The ID of the order to update.

**Response Body:**

```json
{
  "id": "orderId2",
  "customerId": "customerId3",
  "orderDate": "2023-12-21T12:00:00.000Z",
  "totalAmount": 250,
  "status": "SHIPPED"
}
```

### Delete Order

**Method:** DELETE
**Path:** `/orders/{id}`

**Description:** Deletes an order by ID.

**Request Body:** None

**Path Parameters:**

* `id`: The ID of the order to delete.

**Response Body:**

```json
{
  "message": "Order deleted successfully"
}
