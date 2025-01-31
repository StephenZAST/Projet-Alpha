# Tables Additionnelles

## Affiliate System
### Affiliate Levels
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| name | varchar(50) | NOT NULL |
| commissionRate | numeric | NOT NULL |
| minEarnings | numeric | NOT NULL |
| created_at | timestamp with time zone | |
| updated_at | timestamp with time zone | |

### Commission Transactions
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| affiliate_id | uuid | |
| order_id | uuid | NOT NULL |
| amount | numeric | NOT NULL |
| status | USER-DEFINED | NOT NULL |
| created_at | timestamp with time zone | |

## Point System
### Point Transactions
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

### Notifications
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| user_id | uuid | |
| type | USER-DEFINED | NOT NULL |
| message | text | NOT NULL |
| read | boolean | |
| created_at | timestamp with time zone | |
| updated_at | timestamp with time zone | |

## Article Services
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| articleId | uuid | |
| serviceId | uuid | |
| priceMultiplier | numeric | NOT NULL |
| createdAt | timestamp with time zone | |


# Tables Manquantes

## Reward System
### Reward Claims
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| user_id | uuid | |
| reward_id | uuid | |
| points_spent | integer | NOT NULL |
| created_at | timestamp with time zone | |

## User Offers
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| user_id | uuid | |
| offer_id | uuid | |
| order_id | uuid | |
| points_spent | integer | |
| used_at | timestamp with time zone | |
| created_at | timestamp with time zone | |
