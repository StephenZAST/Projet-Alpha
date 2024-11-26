# Permissions Endpoints

This document describes the API endpoints for managing permissions. All endpoints require authentication and admin privileges.

## Get All Permissions

**Method:** GET
**Path:** `/permissions`

**Description:** Retrieves a list of all permissions.

**Request Body:** None

**Response Body:**

```json
[
  {
    "id": "permissionId1",
    "role": "SUPER_ADMIN",
    "resource": "ORDERS",
    "actions": [
      "READ",
      "CREATE",
      "UPDATE",
      "DELETE"
    ],
    "description": "Permissions for managing orders",
    "conditions": {
      // ... optional conditions
    },
    "createdAt": "2023-12-19T12:00:00.000Z",
    "updatedAt": "2023-12-19T12:00:00.000Z"
  },
  // ... more permission entries
]
```

## Get Permission by ID

**Method:** GET
**Path:** `/permissions/{id}`

**Description:** Retrieves a specific permission by its ID.

**Request Body:** None

**Path Parameters:**

* `id`: The ID of the permission to retrieve.

**Response Body:**

```json
{
  "id": "permissionId1",
  "role": "SUPER_ADMIN",
  "resource": "ORDERS",
  "actions": [
    "READ",
    "CREATE",
    "UPDATE",
    "DELETE"
  ],
  "description": "Permissions for managing orders",
  "conditions": {
    // ... optional conditions
  },
  "createdAt": "2023-12-19T12:00:00.000Z",
  "updatedAt": "2023-12-19T12:00:00.000Z"
}
```

## Create Permission

**Method:** POST
**Path:** `/permissions`

**Description:** Creates a new permission.

**Request Body:**

```json
{
  "role": "SUPER_ADMIN",
  "resource": "ORDERS",
  "actions": [
    "READ",
    "CREATE",
    "UPDATE",
    "DELETE"
  ],
  "description": "Permissions for managing orders",
  "conditions": {
    // ... optional conditions
  }
}
```

**Response Body:**

```json
{
  "id": "permissionId2",
  "message": "Permission created successfully"
}
```

## Update Permission

**Method:** PUT
**Path:** `/permissions/{id}`

**Description:** Updates an existing permission by its ID.

**Request Body:**

```json
{
  "actions": [
    "READ",
    "UPDATE",
    "DELETE"
  ],
  "description": "Updated permissions for managing orders",
  "conditions": {
    // ... optional conditions
  }
}
```

**Response Body:**

```json
{
  "id": "permissionId1",
  "message": "Permission updated successfully"
}
```

## Delete Permission

**Method:** DELETE
**Path:** `/permissions/{id}`

**Description:** Deletes a permission by its ID.

**Request Body:** None

**Response Body:**

```json
{
  "message": "Permission deleted successfully"
}
```

## Get Permissions for Role

**Method:** GET
**Path:** `/permissions/role/{roleId}`

**Description:** Retrieves permissions assigned to a specific role.

**Request Body:** None

**Path Parameters:**

* `roleId`: The ID of the role.

**Response Body:**

```json
[
  {
    "id": "permissionId1",
    "role": "SUPER_ADMIN",
    "resource": "ORDERS",
    "actions": [
      "READ",
      "CREATE",
      "UPDATE",
      "DELETE"
    ],
    "description": "Permissions for managing orders",
    "conditions": {
      // ... optional conditions
    },
    "createdAt": "2023-12-19T12:00:00.000Z",
    "updatedAt": "2023-12-19T12:00:00.000Z"
  },
  // ... more permission entries
]
```

## Assign Permission to Role

**Method:** POST
**Path:** `/permissions/role/{roleId}`

**Description:** Assigns a permission to a specific role.

**Request Body:**

```json
{
  "permissionId": "permissionId1"
}
```

**Path Parameters:**

* `roleId`: The ID of the role.

**Response Body:**

```json
{
  "id": "rolePermissionId",
  "message": "Permission assigned to role successfully"
}
```

## Remove Permission from Role

**Method:** DELETE
**Path:** `/permissions/role/{roleId}/{permissionId}`

**Description:** Removes a permission from a specific role.

**Request Body:** None

**Path Parameters:**

* `roleId`: The ID of the role.
* `permissionId`: The ID of the permission.

**Response Body:**

```json
{
  "message": "Permission removed from role successfully"
}
