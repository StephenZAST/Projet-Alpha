# Notifications Endpoints

This document describes the API endpoints for managing notifications.

## Public Routes

### Get All Notifications

**Method:** GET
**Path:** `/notifications`

**Description:** Retrieves a list of all notifications.

**Request Body:** None

**Response Body:**

```json
[
  {
    "id": "notificationId1",
    "title": "Notification 1",
    "message": "This is a notification message",
    "createdAt": "2023-12-19T12:00:00.000Z"
  },
  // ... more notifications
]
```

## Authenticated Routes

### Create Notification

**Method:** POST
**Path:** `/notifications`

**Description:** Creates a new notification.

**Request Body:**

```json
{
  "title": "Notification 2",
  "message": "This is another notification message"
}
```

**Response Body:**

```json
{
  "id": "notificationId2",
  "title": "Notification 2",
  "message": "This is another notification message",
  "createdAt": "2023-12-20T12:00:00.000Z"
}
```

### Update Notification

**Method:** PUT
**Path:** `/notifications/{id}`

**Description:** Updates an existing notification by ID.

**Request Body:**

```json
{
  "title": "Updated Notification 2",
  "message": "This is an updated notification message"
}
```

**Path Parameters:**

* `id`: The ID of the notification to update.

**Response Body:**

```json
{
  "id": "notificationId2",
  "title": "Updated Notification 2",
  "message": "This is an updated notification message",
  "createdAt": "2023-12-20T12:00:00.000Z"
}
```

### Delete Notification

**Method:** DELETE
**Path:** `/notifications/{id}`

**Description:** Deletes a notification by ID.

**Request Body:** None

**Path Parameters:**

* `id`: The ID of the notification to delete.

**Response Body:**

```json
{
  "message": "Notification deleted successfully"
}
