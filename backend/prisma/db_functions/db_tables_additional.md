# Tables Additionnelles
 
## Affiliate System
### Affiliate Levels (Table: affiliate_levels)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| name | varchar(50) | NOT NULL |
| commissionRate | numeric | NOT NULL |
| minEarnings | numeric | NOT NULL |
| created_at | timestamp with time zone | |
| updated_at | timestamp with time zone | |

### Commission Transactions (Table: commissionTransactions)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| affiliate_id | uuid | |
| order_id | uuid | NOT NULL |
| amount | numeric | NOT NULL |
| status | USER-DEFINED | NOT NULL |
| created_at | timestamp with time zone | |
 
## Point System
### Point Transactions (Table: point_transactions)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| userId | uuid | |
| points | integer | |
| type | USER-DEFINED | NOT NULL |
| source | USER-DEFINED | NOT NULL |
| referenceId | varchar(255) | NOT NULL |
| related_transaction_id | uuid | |
| conversion_rate | numeric | |
| createdAt | timestamp with time zone | |

### Notifications (Table: notifications)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| user_id | uuid | |
| type | USER-DEFINED | NOT NULL |
| message | text | NOT NULL |
| read | boolean | |
| created_at | timestamp with time zone | |
| updated_at | timestamp with time zone | |

## Article Services (Table: article_services)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| articleId | uuid | |
| serviceId | uuid | |
| priceMultiplier | numeric | NOT NULL |
| createdAt | timestamp with time zone | |

## Order Management
### Order Metadata (Table: order_metadata)
| Column Name | Type | Constraints |
|------------|------|-------------|
| order_id | uuid | PRIMARY KEY, REFERENCES orders(id) ON DELETE CASCADE |
| is_flash_order | boolean | DEFAULT false |
| metadata | jsonb | DEFAULT '{}'::jsonb |
| created_at | timestamp with time zone | DEFAULT CURRENT_TIMESTAMP |
| updated_at | timestamp with time zone | DEFAULT CURRENT_TIMESTAMP |

# Tables Manquantes

## Reward System
### Reward Claims (Table: reward_claims)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| user_id | uuid | |
| reward_id | uuid | |
| points_spent | integer | NOT NULL |
| created_at | timestamp with time zone | |

## User Offers (Table: user_offers)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| user_id | uuid | |
| offer_id | uuid | |
| order_id | uuid | |
| points_spent | integer | |
| used_at | timestamp with time zone | |
| created_at | timestamp with time zone | |




# Service Management Tables

## Service Types
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL PRIMARY KEY |
| name | varchar(50) | NOT NULL |
| description | text | |
| is_default | boolean | DEFAULT false |
| created_at | timestamptz | DEFAULT now() |
| updated_at | timestamptz | DEFAULT now() |

## Article Service Prices
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL PRIMARY KEY |
| article_id | uuid | REFERENCES articles(id) |
| service_type_id | uuid | REFERENCES service_types(id) |
| base_price | decimal(10,2) | NOT NULL |
| premium_price | decimal(10,2) | |
| is_available | boolean | DEFAULT true |
| price_per_kg | decimal(10,2) | |
| created_at | timestamptz | DEFAULT now() |
| updated_at | timestamptz | DEFAULT now() |





### Article Service Compatibility (Table: article_service_compatibility)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | PRIMARY KEY, NOT NULL |
| article_id | uuid | REFERENCES articles(id) |
| service_id | uuid | REFERENCES services(id) |
| is_compatible | boolean | DEFAULT true |
| created_at | timestamp with time zone | |
| updated_at | timestamp with time zone | |

### Service Specific Prices (Table: service_specific_prices)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | PRIMARY KEY, NOT NULL |
| article_id | uuid | REFERENCES articles(id) |
| service_id | uuid | REFERENCES services(id) |
| base_price | decimal(10,2) | NOT NULL |
| premium_price | decimal(10,2) | |
| created_at | timestamp with time zone | |
| updated_at | timestamp with time zone | |

### Relations
| Source Table | Source Column | Target Table | Target Column |
|-------------|---------------|--------------|---------------|
| services | service_type_id | service_types | id |
| article_service_compatibility | article_id | articles | id |
| article_service_compatibility | service_id | services | id |
| service_specific_prices | article_id | articles | id |
| service_specific_prices | service_id | services | id |


a[
  {
    "table_name": "addresses"
  },
  {
    "table_name": "affiliate_levels"
  },
  {
    "table_name": "affiliate_profiles"
  },
  {
    "table_name": "article_archives"
  },
  {
    "table_name": "article_categories"
  },
  {
    "table_name": "article_service_compatibility"
  },
  {
    "table_name": "article_service_prices"
  },
  {
    "table_name": "article_services"
  },
  {
    "table_name": "articles"
  },
  {
    "table_name": "blog_articles"
  },
  {
    "table_name": "blog_categories"
  },
  {
    "table_name": "commissionTransactions"
  },
  {
    "table_name": "discount_rules"
  },
  {
    "table_name": "loyalty_points"
  },
  {
    "table_name": "notification_preferences"
  },
  {
    "table_name": "notification_rules"
  },
  {
    "table_name": "notifications"
  },
  {
    "table_name": "offer_articles"
  },
  {
    "table_name": "offers"
  },
  {
    "table_name": "order_items"
  },
  {
    "table_name": "order_metadata"
  },
  {
    "table_name": "order_notes"
  },
  {
    "table_name": "order_weights"
  },
  {
    "table_name": "orders"
  },
  {
    "table_name": "orders_archive"
  },
  {
    "table_name": "point_transactions"
  },
  {
    "table_name": "price_configurations"
  },
  {
    "table_name": "price_history"
  },
  {
    "table_name": "reset_codes"
  },
  {
    "table_name": "reward_claims"
  },
  {
    "table_name": "rewards"
  },
  {
    "table_name": "service_specific_prices"
  },
  {
    "table_name": "service_types"
  },
  {
    "table_name": "services"
  },
  {
    "table_name": "subscription_plans"
  },
  {
    "table_name": "temp_notifications"
  },
  {
    "table_name": "user_offers"
  },
  {
    "table_name": "user_subscriptions"
  },
  {
    "table_name": "users"
  },
  {
    "table_name": "weight_based_pricing"
  }
]