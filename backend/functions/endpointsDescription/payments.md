# Payments Endpoints

This document describes the API endpoints for managing payments.

## Public Routes

### Get All Payments

**Method:** GET
**Path:** `/payments`

**Description:** Retrieves a list of all payments.

**Request Body:** None

**Response Body:**

```json
[
  {
    "id": "paymentId1",
    "amount": 100,
    "paymentMethod": "CREDIT_CARD",
    "paymentStatus": "SUCCESS"
  },
  // ... more payments
]
```

## Authenticated Routes

### Create Payment

**Method:** POST
**Path:** `/payments`

**Description:** Creates a new payment.

**Request Body:**

```json
{
  "amount": 200,
  "paymentMethod": "PAYPAL"
}
```

**Response Body:**

```json
{
  "id": "paymentId2",
  "amount": 200,
  "paymentMethod": "PAYPAL",
  "paymentStatus": "PENDING"
}
```

### Update Payment

**Method:** PUT
**Path:** `/payments/{id}`

**Description:** Updates an existing payment by ID.

**Request Body:**

```json
{
  "amount": 250,
  "paymentMethod": "CREDIT_CARD"
}
```

**Path Parameters:**

* `id`: The ID of the payment to update.

**Response Body:**

```json
{
  "id": "paymentId2",
  "amount": 250,
  "paymentMethod": "CREDIT_CARD",
  "paymentStatus": "PENDING"
}
```

### Delete Payment

**Method:** DELETE
**Path:** `/payments/{id}`

**Description:** Deletes a payment by ID.

**Request Body:** None

**Path Parameters:**

* `id`: The ID of the payment to delete.

**Response Body:**

```json
{
  "message": "Payment deleted successfully"
}
