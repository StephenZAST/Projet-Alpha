# Admins Endpoints

This document describes the API endpoints for managing admins.

## Public Routes

### Login

**Method:** POST
**Path:** `/admins/login`

**Description:** Logs in an admin user.

**Request Body:**

```json
{
  "email": "admin@example.com",
  "password": "password123"
}
```

**Response Body:**

```json
{
  "success": true,
  "data": {
    "admin": {
      "_id": "adminId",
      // ... other admin fields
    },
    "token": "jwtToken"
  }
}
```

## Protected Routes (Require Authentication)

### Create Master Admin (One-Time Use)

**Method:** POST
**Path:** `/admins/master/create`

**Description:** Creates the initial master admin account. This endpoint should only be used once during the initial setup of the application.

**Request Body:**

```json
{
  // Admin data (details not specified in the code)
}
```

**Response Body:**

```json
{
  "success": true,
  "data": {
    // Created master admin data
  }
}
```

### Get All Admins

**Method:** GET
**Path:** `/admins/all`

**Description:** Retrieves a list of all admin users. Accessible by Super Admin Master and Super Admin.

**Request Body:** None

**Response Body:**

```json
{
  "success": true,
  "data": [
    {
      "_id": "adminId",
      // ... other admin fields
    },
    // ... more admin entries
  ]
}
```

### Create Admin

**Method:** POST
**Path:** `/admins/create`

**Description:** Creates a new admin user. Accessible by Super Admin Master and Super Admin.

**Request Body:**

```json
{
  // Admin data (details not specified in the code)
}
```

**Response Body:**

```json
{
  "success": true,
  "data": {
    // Created admin data
  }
}
```

### Create Super Admin (Super Admin Master Only)

**Method:** POST
**Path:** `/admins/super-admin/create`

**Description:** Creates a new super admin user. Accessible only by Super Admin Master.

**Request Body:**

```json
{
  // Admin data (details not specified in the code)
}
```

**Response Body:**

```json
{
  "success": true,
  "data": {
    // Created super admin data
  }
}
```

### Delete Super Admin (Super Admin Master Only)

**Method:** DELETE
**Path:** `/admins/super-admin/{id}`

**Description:** Deletes a super admin user by ID. Accessible only by Super Admin Master.

**Request Body:** None

**Response Body:**

```json
{
  "success": true,
  "message": "Admin deleted successfully"
}
```

### Update Super Admin (Super Admin Master Only)

**Method:** PUT
**Path:** `/admins/super-admin/{id}`

**Description:** Updates a super admin user by ID. Accessible only by Super Admin Master.

**Request Body:**

```json
{
  // Updated admin data
}
```

**Response Body:**

```json
{
  "success": true,
  "data": {
    // Updated super admin data
  }
}
```

### Get Admin Profile

**Method:** GET
**Path:** `/admins/profile`

**Description:** Retrieves the profile of the currently authenticated admin user.

**Request Body:** None

**Response Body:**

```json
{
  "success": true,
  "data": {
    // Admin profile data
  }
}
```

### Update Admin Profile

**Method:** PUT
**Path:** `/admins/profile`

**Description:** Updates the profile of the currently authenticated admin user.

**Request Body:**

```json
{
  // Updated admin data
}
```

**Response Body:**

```json
{
  "success": true,
  "data": {
    // Updated admin data
  }
}
```

### Get Admin by ID

**Method:** GET
**Path:** `/admins/{id}`

**Description:** Retrieves an admin user by ID. Accessible by all admins to view other admins.

**Request Body:** None

**Response Body:**

```json
{
  "success": true,
  "data": {
    // Admin data
  }
}
```

### Update Admin

**Method:** PUT
**Path:** `/admins/{id}`

**Description:** Updates an admin user by ID. Accessible by all admins to modify other admins.

**Request Body:**

```json
{
  // Updated admin data
}
```

**Response Body:**

```json
{
  "success": true,
  "data": {
    // Updated admin data
  }
}
```

### Delete Admin

**Method:** DELETE
**Path:** `/admins/{id}`

**Description:** Deletes an admin user by ID. Accessible by all admins to delete other admins.

**Request Body:** None

**Response Body:**

```json
{
  "success": true,
  "message": "Admin deleted successfully"
}
```

### Toggle Admin Status

**Method:** PUT
**Path:** `/admins/{id}/status`

**Description:** Toggles the active/inactive status of an admin user by ID.

**Request Body:**

```json
{
  "isActive": true
}
```

**Response Body:**

```json
{
  "success": true,
  "data": {
    // Updated admin data
  }
}
