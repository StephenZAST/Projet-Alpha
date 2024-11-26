# Affiliates Endpoints

This document describes the API endpoints for managing affiliates.

## Public Routes

### Register Affiliate

**Method:** POST
**Path:** `/affiliates/register`

**Description:** Registers a new affiliate user.

**Request Body:**

```json
{
  "fullName": "John Doe",
  "email": "john.doe@example.com",
  "phone": "+1234567890",
  "paymentInfo": {
    "preferredMethod": "MOBILE_MONEY",
    "mobileMoneyNumber": "+237699999999"
  }
}
```

**Response Body:**

```json
{
  "success": true,
  "data": {
    "id": "affiliateId",
    // ... other affiliate fields
  }
}
```

### Affiliate Login

**Method:** POST
**Path:** `/affiliates/login`

**Description:** Allows an affiliate user to log in.

**Request Body:**

```json
{
  "email": "john.doe@example.com",
  "password": "password123"
}
```

**Response Body:**

```json
{
  "success": true,
  "data": {
    "token": "jwtToken",
    "affiliate": {
      "id": "affiliateId",
      // ... other affiliate fields
    }
  }
}
```

## Affiliate-Protected Routes (Require Authentication)

### Get Affiliate Profile

**Method:** GET
**Path:** `/affiliates/profile`

**Description:** Retrieves the profile of the currently authenticated affiliate user.

**Request Body:** None

**Response Body:**

```json
{
  "success": true,
  "data": {
    "id": "affiliateId",
    // ... other affiliate fields
  }
}
```

### Update Affiliate Profile

**Method:** PUT
**Path:** `/affiliates/profile`

**Description:** Updates the profile of the currently authenticated affiliate user.

**Request Body:**

```json
{
  "fullName": "John Doe",
  "phone": "+1234567890",
  "paymentInfo": {
    "preferredMethod": "MOBILE_MONEY",
    "mobileMoneyNumber": "+237699999999"
  }
}
```

**Response Body:**

```json
{
  "success": true,
  "message": "Profile updated successfully"
}
```

### Get Affiliate Statistics

**Method:** GET
**Path:** `/affiliates/stats`

**Description:** Retrieves the statistics of the currently authenticated affiliate user.

**Request Body:** None

**Response Body:**

```json
{
  "success": true,
  "data": {
    // Affiliate statistics data
  }
}
```

### Get Affiliate Commissions

**Method:** GET
**Path:** `/affiliates/commissions`

**Description:** Retrieves a list of commissions earned by the currently authenticated affiliate user.

**Request Body:** None

**Response Body:**

```json
{
  "success": true,
  "data": [
    {
      "id": "commissionId",
      // ... other commission fields
    },
    // ... more commission entries
  ]
}
```

### Request Commission Withdrawal

**Method:** POST
**Path:** `/affiliates/withdrawal/request`

**Description:** Allows an affiliate user to request a withdrawal of their earned commissions.

**Request Body:**

```json
{
  "amount": 10000,
  "paymentMethod": "MOBILE_MONEY"
}
```

**Response Body:**

```json
{
  "success": true,
  "data": {
    "id": "withdrawalId",
    // ... other withdrawal fields
  }
}
```

### Get Affiliate Withdrawal History

**Method:** GET
**Path:** `/affiliates/withdrawals`

**Description:** Retrieves a list of withdrawal requests made by the currently authenticated affiliate user.

**Request Body:** None

**Response Body:**

```json
{
  "success": true,
  "data": [
    {
      "id": "withdrawalId",
      // ... other withdrawal fields
    },
    // ... more withdrawal entries
  ]
}
```

## Admin/Secretary-Protected Routes (Require Authentication and Authorization)

### Get Pending Affiliates

**Method:** GET
**Path:** `/affiliates/pending`

**Description:** Retrieves a list of affiliate applications that are pending approval.

**Request Body:** None

**Response Body:**

```json
{
  "success": true,
  "data": [
    {
      "id": "affiliateId",
      // ... other affiliate fields
    },
    // ... more affiliate entries
  ]
}
```

### Approve Affiliate

**Method:** POST
**Path:** `/affiliates/{id}/approve`

**Description:** Approves an affiliate application by ID.

**Request Body:** None

**Response Body:**

```json
{
  "success": true,
  "message": "Affiliate approved successfully"
}
```

### Get Pending Withdrawals

**Method:** GET
**Path:** `/affiliates/withdrawals/pending`

**Description:** Retrieves a list of withdrawal requests that are pending processing.

**Request Body:** None

**Response Body:**

```json
{
  "success": true,
  "data": [
    {
      "id": "withdrawalId",
      // ... other withdrawal fields
    },
    // ... more withdrawal entries
  ]
}
```

### Process Withdrawal

**Method:** POST
**Path:** `/affiliates/withdrawal/{id}/process`

**Description:** Processes a withdrawal request by ID.

**Request Body:**

```json
{
  "status": "COMPLETED",
  "notes": "Withdrawal processed successfully"
}
```

**Response Body:**

```json
{
  "success": true,
  "message": "Withdrawal processed successfully"
}
```

## Admin-Only Routes (Require Authentication and Admin Role)

### Get All Affiliates

**Method:** GET
**Path:** `/affiliates/all`

**Description:** Retrieves a list of all affiliate users.

**Request Body:** None

**Response Body:**

```json
{
  "success": true,
  "data": [
    {
      "id": "affiliateId",
      // ... other affiliate fields
    },
    // ... more affiliate entries
  ]
}
```

### Update Commission Rules

**Method:** POST
**Path:** `/affiliates/commission-rules`

**Description:** Updates the commission rules for affiliates.

**Request Body:**

```json
{
  "ruleId": "ruleId",
  "updates": {
    // Updated commission rule data
  }
}
```

**Response Body:**

```json
{
  "success": true,
  "message": "Commission rules updated successfully"
}
```

### Get Affiliate Analytics

**Method:** GET
**Path:** `/affiliates/analytics`

**Description:** Retrieves analytics data for the affiliate system.

**Request Body:** None

**Response Body:**

```json
{
  "success": true,
  "data": {
    // Affiliate system analytics data
  }
}
