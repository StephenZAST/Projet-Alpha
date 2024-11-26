# Analytics Endpoints

This document describes the API endpoints for retrieving business analytics and reporting data. All endpoints require authentication and admin privileges.

## Get Revenue Analytics

**Method:** GET
**Path:** `/analytics/revenue`

**Description:** Retrieves detailed revenue metrics for a specified time period.

**Request Body:** None

**Query Parameters:**

* `startDate`: Start date for the analysis period (YYYY-MM-DD).
* `endDate`: End date for the analysis period (YYYY-MM-DD).

**Response Body:**

```json
{
  "totalRevenue": 12345.67,
  "periodRevenue": 12345.67,
  "orderCount": 100,
  "averageOrderValue": 123.45,
  "revenueByService": {
    "service1": 5000,
    "service2": 7345.67
  },
  "periodStart": "2023-12-19T12:00:00.000Z",
  "periodEnd": "2023-12-25T12:00:00.000Z"
}
```

## Get Customer Analytics

**Method:** GET
**Path:** `/analytics/customers`

**Description:** Retrieves detailed customer metrics including retention and loyalty statistics.

**Request Body:** None

**Response Body:**

```json
{
  "totalCustomers": 1000,
  "activeCustomers": 800,
  "customerRetentionRate": 80,
  "topCustomers": [
    {
      "userId": "customerId1",
      "totalSpent": 1500,
      "orderCount": 5,
      "loyaltyTier": "GOLD",
      "lastOrderDate": "2023-12-20T12:00:00.000Z"
    },
    // ... more top customers
  ],
  "customersByTier": {
    "BRONZE": 200,
    "SILVER": 300,
    "GOLD": 400,
    "PLATINUM": 100
  }
}
```

## Get Affiliate Analytics

**Method:** GET
**Path:** `/analytics/affiliates`

**Description:** Retrieves detailed affiliate performance metrics for a specified time period.

**Request Body:** None

**Query Parameters:**

* `startDate`: Start date for the analysis period (YYYY-MM-DD).
* `endDate`: End date for the analysis period (YYYY-MM-DD).

**Response Body:**

```json
{
  "totalAffiliates": 50,
  "activeAffiliates": 40,
  "totalCommissions": 10000,
  "topAffiliates": [
    {
      "affiliateId": "affiliateId1",
      "activeCustomers": 10,
      "totalCommission": 2000
    },
    // ... more top affiliates
  ],
  "commissionsPerPeriod": {
    // ... commissions data for the specified period
  }
}
