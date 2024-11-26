# Admin Logs Endpoints

This document describes the API endpoints for managing admin logs. All endpoints require authentication and admin privileges.

## Get All Admin Logs

**Method:** GET
**Path:** `/adminLogs`

**Description:** Retrieves a list of all admin logs, sorted by creation date in descending order.

**Request Body:** None

**Response Body:**

```json
[
  {
    "id": "logId",
    "adminId": "adminUserId",
    "adminName": "Admin User Name",
    "action": "LOGGED_IN",
    "details": "Admin logged in from IP address 192.168.1.1",
    "createdAt": "2023-12-19T12:00:00.000Z",
    "updatedAt": "2023-12-19T12:00:00.000Z"
  },
  // ... more log entries
]
```

## Get Admin Log by ID

**Method:** GET
**Path:** `/adminLogs/{id}`

**Description:** Retrieves a specific admin log by its ID.

**Request Body:** None

**Response Body:**

```json
{
  "id": "logId",
  "adminId": "adminUserId",
  "adminName": "Admin User Name",
  "action": "LOGGED_IN",
  "details": "Admin logged in from IP address 192.168.1.1",
  "createdAt": "2023-12-19T12:00:00.000Z",
  "updatedAt": "2023-12-19T12:00:00.000Z"
}
```

## Create a New Admin Log

**Method:** POST
**Path:** `/adminLogs`

**Description:** Creates a new admin log entry.

**Request Body:**

```json
{
  "action": "LOGGED_IN",
  "details": "Admin logged in from IP address 192.168.1.1"
}
```

**Response Body:**

```json
{
  "id": "logId",
  "message": "Admin log created successfully"
}
```

## Update an Existing Admin Log

**Method:** PUT
**Path:** `/adminLogs/{id}`

**Description:** Updates an existing admin log entry by its ID.

**Request Body:**

```json
{
  "action": "UPDATED_PROFILE",
  "details": "Admin updated their profile information"
}
```

**Response Body:**

```json
{
  "id": "logId",
  "message": "Admin log updated successfully"
}
```

## Delete an Admin Log

**Method:** DELETE
**Path:** `/adminLogs/{id}`

**Description:** Deletes an admin log entry by its ID.

**Request Body:** None

**Response Body:**

```json
{
  "message": "Admin log deleted successfully"
}
