# Teams Endpoints

This document describes the API endpoints for managing teams.

## Public Routes

### Get All Teams

**Method:** GET
**Path:** `/teams`

**Description:** Retrieves a list of all teams.

**Request Body:** None

**Response Body:**

```json
[
  {
    "id": "teamId1",
    "name": "Team 1",
    "description": "Team 1 description",
    "members": [
      {
        "id": "memberId1",
        "name": "Member 1",
        "email": "member1@example.com"
      },
      // ... more members
    ]
  },
  // ... more teams
]
```

## Authenticated Routes

### Create Team

**Method:** POST
**Path:** `/teams`

**Description:** Creates a new team.

**Request Body:**

```json
{
  "name": "Team 2",
  "description": "Team 2 description"
}
```

**Response Body:**

```json
{
  "id": "teamId2",
  "name": "Team 2",
  "description": "Team 2 description",
  "members": []
}
```

### Update Team

**Method:** PUT
**Path:** `/teams/{id}`

**Description:** Updates an existing team by ID.

**Request Body:**

```json
{
  "name": "Updated Team 2",
  "description": "Updated Team 2 description"
}
```

**Path Parameters:**

* `id`: The ID of the team to update.

**Response Body:**

```json
{
  "id": "teamId2",
  "name": "Updated Team 2",
  "description": "Updated Team 2 description",
  "members": []
}
```

### Delete Team

**Method:** DELETE
**Path:** `/teams/{id}`

**Description:** Deletes a team by ID.

**Request Body:** None

**Path Parameters:**

* `id`: The ID of the team to delete.

**Response Body:**

```json
{
  "message": "Team deleted successfully"
}
```

### Add Member to Team

**Method:** POST
**Path:** `/teams/{id}/members`

**Description:** Adds a member to a team by ID.

**Request Body:**

```json
{
  "memberId": "memberId3"
}
```

**Path Parameters:**

* `id`: The ID of the team to add the member to.

**Response Body:**

```json
{
  "id": "teamId2",
  "name": "Updated Team 2",
  "description": "Updated Team 2 description",
  "members": [
    {
      "id": "memberId3",
      "name": "Member 3",
      "email": "member3@example.com"
    }
  ]
}
```

### Remove Member from Team

**Method:** DELETE
**Path:** `/teams/{id}/members/{memberId}`

**Description:** Removes a member from a team by ID.

**Request Body:** None

**Path Parameters:**

* `id`: The ID of the team to remove the member from.
* `memberId`: The ID of the member to remove.

**Response Body:**

```json
{
  "id": "teamId2",
  "name": "Updated Team 2",
  "description": "Updated Team 2 description",
  "members": []
}
