# Articles Endpoints

This document describes the API endpoints for managing articles.

## Public Routes

### Get All Articles

**Method:** GET
**Path:** `/articles`

**Description:** Retrieves a list of all articles.

**Request Body:** None

**Response Body:**

```json
[
  {
    "articleId": "articleId1",
    "articleName": "Article Title 1",
    "articleCategory": "Category 1",
    "prices": {
      "PRESSING": {
        "FIXED": 1000,
        "PER_KG": 2000
      },
      // ... other services
    },
    "availableServices": [
      "PRESSING",
      "DRY_CLEANING",
      // ... other services
    ],
    "availableAdditionalServices": [
      "STARCHING",
      "FOLDING",
      // ... other additional services
    ],
    "createdAt": "2023-12-19T12:00:00.000Z",
    "updatedAt": "2023-12-19T12:00:00.000Z"
  },
  // ... more article entries
]
```

## Admin-Only Routes (Require Authentication and Admin Role)

### Create Article

**Method:** POST
**Path:** `/articles`

**Description:** Creates a new article.

**Request Body:**

```json
{
  "articleName": "Article Title 2",
  "articleCategory": "Category 2",
  "prices": {
    "PRESSING": {
      "FIXED": 1500,
      "PER_KG": 2500
    },
    // ... other services
  },
  "availableServices": [
    "PRESSING",
    "DRY_CLEANING",
    // ... other services
  ],
  "availableAdditionalServices": [
    "STARCHING",
    "FOLDING",
    // ... other additional services
  ]
}
```

**Response Body:**

```json
{
  "articleId": "articleId2",
  "articleName": "Article Title 2",
  "articleCategory": "Category 2",
  "prices": {
    "PRESSING": {
      "FIXED": 1500,
      "PER_KG": 2500
    },
    // ... other services
  },
  "availableServices": [
    "PRESSING",
    "DRY_CLEANING",
    // ... other services
  ],
  "availableAdditionalServices": [
    "STARCHING",
    "FOLDING",
    // ... other additional services
  ],
  "createdAt": "2023-12-19T12:00:00.000Z",
  "updatedAt": "2023-12-19T12:00:00.000Z"
}
```

### Update Article

**Method:** PUT
**Path:** `/articles/{id}`

**Description:** Updates an existing article by ID.

**Request Body:**

```json
{
  "articleName": "Updated Article Title",
  "articleCategory": "Category 3",
  "prices": {
    "PRESSING": {
      "FIXED": 2000,
      "PER_KG": 3000
    },
    // ... other services
  },
  "availableServices": [
    "PRESSING",
    "DRY_CLEANING",
    // ... other services
  ],
  "availableAdditionalServices": [
    "STARCHING",
    "FOLDING",
    // ... other additional services
  ]
}
```

**Response Body:**

```json
{
  "articleId": "articleId1",
  "articleName": "Updated Article Title",
  "articleCategory": "Category 3",
  "prices": {
    "PRESSING": {
      "FIXED": 2000,
      "PER_KG": 3000
    },
    // ... other services
  },
  "availableServices": [
    "PRESSING",
    "DRY_CLEANING",
    // ... other services
  ],
  "availableAdditionalServices": [
    "STARCHING",
    "FOLDING",
    // ... other additional services
  ],
  "createdAt": "2023-12-19T12:00:00.000Z",
  "updatedAt": "2023-12-19T12:00:00.000Z"
}
```

### Delete Article

**Method:** DELETE
**Path:** `/articles/{id}`

**Description:** Deletes an article by ID.

**Request Body:** None

**Response Body:**

```json
{
  "message": "Article deleted successfully"
}
