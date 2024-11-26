# Categories Endpoints

This document describes the API endpoints for managing categories.

## Public Routes

### Get All Categories

**Method:** GET
**Path:** `/categories`

**Description:** Retrieves a list of all categories.

**Request Body:** None

**Response Body:**

```json
[
  {
    "id": "categoryId1",
    "name": "Category 1",
    "description": "Category 1 description"
  },
  // ... more categories
]
```

## Authenticated Routes

### Create Category

**Method:** POST
**Path:** `/categories`

**Description:** Creates a new category.

**Request Body:**

```json
{
  "name": "Category 2",
  "description": "Category 2 description"
}
```

**Response Body:**

```json
{
  "id": "categoryId2",
  "name": "Category 2",
  "description": "Category 2 description"
}
```

### Update Category

**Method:** PUT
**Path:** `/categories/{id}`

**Description:** Updates an existing category by ID.

**Request Body:**

```json
{
  "name": "Updated Category 2",
  "description": "Updated Category 2 description"
}
```

**Path Parameters:**

* `id`: The ID of the category to update.

**Response Body:**

```json
{
  "id": "categoryId2",
  "name": "Updated Category 2",
  "description": "Updated Category 2 description"
}
```

### Delete Category

**Method:** DELETE
**Path:** `/categories/{id}`

**Description:** Deletes a category by ID.

**Request Body:** None

**Path Parameters:**

* `id`: The ID of the category to delete.

**Response Body:**

```json
{
  "message": "Category deleted successfully"
}
