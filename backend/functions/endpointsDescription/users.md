# Users Endpoints

This document describes the API endpoints for managing users.

## Public Routes

### Get All Users

**Method:** GET
**Path:** `/users`

**Description:** Retrieves a list of all users.

**Request Body:** None

**Response Body:**

```json
[
  {
    "id": "userId1",
    "name": "User 1",
    "email": "user1@example.com",
    "role": "CLIENT"
  },
  // ... more users
]
```

## Authenticated Routes

### Create User

**Method:** POST
**Path:** `/users`

**Description:** Creates a new user.

**Request Body:**

```json
{
  "name": "User 2",
  "email": "user2@example.com",
  "password": "password123",
  "role": "CLIENT"
}
```

**Response Body:**

```json
{
  "id": "userId2",
  "name": "User 2",
  "email": "user2@example.com",
  "role": "CLIENT"
}
```

### Update User

**Method:** PUT
**Path:** `/users/{id}`

**Description:** Updates an existing user by ID.

**Request Body:**

```json
{
  "name": "Updated User 2",
  "email": "updateduser2@example.com"
}
```

**Path Parameters:**

* `id`: The ID of the user to update.

**Response Body:**

```json
{
  "id": "userId2",
  "name": "Updated User 2",
  "email": "updateduser2@example.com",
  "role": "CLIENT"
}
```

### Delete User

**Method:** DELETE
**Path:** `/users/{id}`

**Description:** Deletes a user by ID.

**Request Body:** None

**Path Parameters:**

* `id`: The ID of the user to delete.

**Response Body:**

```json
{
  "message": "User deleted successfully"
}
