# Zones Endpoints

This document describes the API endpoints for managing zones.

## Public Routes

### Get All Zones

**Method:** GET
**Path:** `/zones`

**Description:** Retrieves a list of all zones.

**Request Body:** None

**Response Body:**

```json
[
  {
    "id": "zoneId1",
    "name": "Zone 1",
    "description": "Zone 1 description",
    "areas": [
      {
        "id": "areaId1",
        "name": "Area 1",
        "description": "Area 1 description"
      },
      // ... more areas
    ]
  },
  // ... more zones
]
```

## Authenticated Routes

### Create Zone

**Method:** POST
**Path:** `/zones`

**Description:** Creates a new zone.

**Request Body:**

```json
{
  "name": "Zone 2",
  "description": "Zone 2 description"
}
```

**Response Body:**

```json
{
  "id": "zoneId2",
  "name": "Zone 2",
  "description": "Zone 2 description",
  "areas": []
}
```

### Update Zone

**Method:** PUT
**Path:** `/zones/{id}`

**Description:** Updates an existing zone by ID.

**Request Body:**

```json
{
  "name": "Updated Zone 2",
  "description": "Updated Zone 2 description"
}
```

**Path Parameters:**

* `id`: The ID of the zone to update.

**Response Body:**

```json
{
  "id": "zoneId2",
  "name": "Updated Zone 2",
  "description": "Updated Zone 2 description",
  "areas": []
}
```

### Delete Zone

**Method:** DELETE
**Path:** `/zones/{id}`

**Description:** Deletes a zone by ID.

**Request Body:** None

**Path Parameters:**

* `id`: The ID of the zone to delete.

**Response Body:**

```json
{
  "message": "Zone deleted successfully"
}
```

### Add Area to Zone

**Method:** POST
**Path:** `/zones/{id}/areas`

**Description:** Adds an area to a zone by ID.

**Request Body:**

```json
{
  "areaId": "areaId3"
}
```

**Path Parameters:**

* `id`: The ID of the zone to add the area to.

**Response Body:**

```json
{
  "id": "zoneId2",
  "name": "Updated Zone 2",
  "description": "Updated Zone 2 description",
  "areas": [
    {
      "id": "areaId3",
      "name": "Area 3",
      "description": "Area 3 description"
    }
  ]
}
```

### Remove Area from Zone

**Method:** DELETE
**Path:** `/zones/{id}/areas/{areaId}`

**Description:** Removes an area from a zone by ID.

**Request Body:** None

**Path Parameters:**

* `id`: The ID of the zone to remove the area from.
* `areaId`: The ID of the area to remove.

**Response Body:**

```json
{
  "id": "zoneId2",
  "name": "Updated Zone 2",
  "description": "Updated Zone 2 description",
  "areas": []
}
