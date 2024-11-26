# Delivery Tasks Endpoints

This document describes the API endpoints for managing delivery tasks.

## Public Routes

### Get All Delivery Tasks

**Method:** GET
**Path:** `/delivery-tasks`

**Description:** Retrieves a list of all delivery tasks.

**Request Body:** None

**Response Body:**

```json
[
  {
    "id": "deliveryTaskId1",
    "taskId": "taskId1",
    "deliveryDate": "2023-12-19T12:00:00.000Z",
    "status": "PENDING"
  },
  // ... more delivery tasks
]
```

## Authenticated Routes

### Create Delivery Task

**Method:** POST
**Path:** `/delivery-tasks`

**Description:** Creates a new delivery task.

**Request Body:**

```json
{
  "taskId": "taskId2",
  "deliveryDate": "2023-12-20T12:00:00.000Z"
}
```

**Response Body:**

```json
{
  "id": "deliveryTaskId2",
  "taskId": "taskId2",
  "deliveryDate": "2023-12-20T12:00:00.000Z",
  "status": "PENDING"
}
```

### Update Delivery Task

**Method:** PUT
**Path:** `/delivery-tasks/{id}`

**Description:** Updates an existing delivery task by ID.

**Request Body:**

```json
{
  "deliveryDate": "2023-12-21T12:00:00.000Z"
}
```

**Path Parameters:**

* `id`: The ID of the delivery task to update.

**Response Body:**

```json
{
  "id": "deliveryTaskId2",
  "taskId": "taskId2",
  "deliveryDate": "2023-12-21T12:00:00.000Z",
  "status": "PENDING"
}
```

### Delete Delivery Task

**Method:** DELETE
**Path:** `/delivery-tasks/{id}`

**Description:** Deletes a delivery task by ID.

**Request Body:** None

**Path Parameters:**

* `id`: The ID of the delivery task to delete.

**Response Body:**

```json
{
  "message": "Delivery task deleted successfully"
}
