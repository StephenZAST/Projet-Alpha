# Loyalty Endpoints

This document describes the API endpoints for managing loyalty points and rewards.

## Public Routes

### Get All Loyalty Points

**Method:** GET
**Path:** `/loyalty`

**Description:** Retrieves a list of all loyalty points.

**Request Body:** None

**Response Body:**

```json
[
  {
    "id": "loyaltyId1",
    "userId": "userId1",
    "points": 100,
    "createdAt": "2023-12-19T12:00:00.000Z"
  },
  // ... more loyalty points
]
```

## Authenticated Routes

### Create Loyalty Point

**Method:** POST
**Path:** `/loyalty`

**Description:** Creates a new loyalty point.

**Request Body:**

```json
{
  "userId": "userId2",
  "points": 200
}
```

**Response Body:**

```json
{
  "id": "loyaltyId2",
  "userId": "userId2",
  "points": 200,
  "createdAt": "2023-12-20T12:00:00.000Z"
}
```

### Update Loyalty Point

**Method:** PUT
**Path:** `/loyalty/{id}`

**Description:** Updates an existing loyalty point by ID.

**Request Body:**

```json
{
  "points": 250
}
```

**Path Parameters:**

* `id`: The ID of the loyalty point to update.

**Response Body:**

```json
{
  "id": "loyaltyId2",
  "userId": "userId2",
  "points": 250,
  "createdAt": "2023-12-20T12:00:00.000Z"
}
```

### Delete Loyalty Point

**Method:** DELETE
**Path:** `/loyalty/{id}`

**Description:** Deletes a loyalty point by ID.

**Request Body:** None

**Path Parameters:**

* `id`: The ID of the loyalty point to delete.

**Response Body:**

```json
{
  "message": "Loyalty point deleted successfully"
}
