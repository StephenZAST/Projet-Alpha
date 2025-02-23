# Database Structure
 
## User Management
### Users (Table: users)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| first_name | varchar(100) | NOT NULL |
| last_name | varchar(100) | NOT NULL |
| email | varchar(255) | NOT NULL |
| password | varchar(255) | NOT NULL |
| phone | varchar(20) | |
| role | USER-DEFINED | |
| referral_code | varchar(20) | |
| created_at | timestamp with time zone | |
| updated_at | timestamp with time zone | |
 
### Addresses (Table: addresses)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| user_id | uuid | |
| name | varchar(255) | |
| street | varchar(255) | NOT NULL |
| city | varchar(100) | NOT NULL |
| postal_code | varchar(20) | |
| gps_latitude | numeric | |
| gps_longitude | numeric | |
| is_default | boolean | |
| created_at | timestamp with time zone | |
| updated_at | timestamp with time zone | |

## Articles and Services
### Articles (Table: articles)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| name | varchar(255) | NOT NULL |
| description | text | |
| basePrice | numeric | NOT NULL |
| premiumPrice | numeric | |
| categoryId | uuid | |
| createdAt | timestamp with time zone | |
| updatedAt | timestamp with time zone | |

### Services (Table: services)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| name | varchar(100) | NOT NULL |
| description | text | |
| price | integer | |
| created_at | timestamp with time zone | |
| updated_at | timestamp with time zone | |

## Orders
### Orders (Table: orders)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| userId | uuid | NOT NULL |
| totalAmount | numeric | |
| status | USER-DEFINED | |
| isRecurring | boolean | |
| recurrenceType | USER-DEFINED | |
| nextRecurrenceDate | timestamp with time zone | |
| collectionDate | timestamp with time zone | |
| deliveryDate | timestamp with time zone | |
| addressId | uuid | |
| serviceId | uuid | |
| service_type_id | uuid | |
| affiliateCode | text | |
| paymentMethod | USER-DEFINED | |
| createdAt | timestamp with time zone | |
| updatedAt | timestamp with time zone | |

## Loyalty System
### Loyalty Points (Table: loyalty_points)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| user_id | uuid | |
| pointsBalance | integer | |
| totalEarned | integer | |
| createdAt | timestamp with time zone | |
| updatedAt | timestamp with time zone | |

### Rewards (Table: rewards)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| name | varchar(255) | NOT NULL |
| description | text | |
| points_cost | integer | NOT NULL |
| available | boolean | |
| created_at | timestamp with time zone | |
| updated_at | timestamp with time zone | |

## Affiliate System
### Affiliate Profiles (Table: affiliate_profiles)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| user_id | uuid | NOT NULL |
| affiliate_code | varchar(255) | NOT NULL |
| status | USER-DEFINED | |
| is_active | boolean | |
| commission_rate | numeric | |
| commission_balance | numeric | |
| total_earned | numeric | |
| monthly_earnings | numeric | |
| total_referrals | integer | |
| level_id | uuid | |
| parent_affiliate_id | uuid | |
| created_at | timestamp with time zone | |
| updated_at | timestamp with time zone | |

## Blog System
### Blog Articles (Table: blog_articles)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| title | varchar(255) | NOT NULL |
| content | text | NOT NULL |
| author_id | uuid | NOT NULL |
| category_id | uuid | |
| is_published | boolean | |
| published_at | timestamp with time zone | |
| created_at | timestamp with time zone | |
| updated_at | timestamp with time zone | |

## Offers and Discounts
### Offers (Table: offers)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| name | varchar(255) | NOT NULL |
| description | text | |
| discountType | varchar(20) | NOT NULL |
| discountValue | numeric | NOT NULL |
| minPurchaseAmount | numeric | |
| maxDiscountAmount | numeric | |
| points_required | integer | |
| pointsRequired | numeric | |
| isCumulative | boolean | |
| startDate | timestamp with time zone | |
| endDate | timestamp with time zone | |
| is_active | boolean | |
| created_at | timestamp with time zone | |
| updated_at | timestamp with time zone | |

### Discount Rules (Table: discount_rules)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| offer_id | uuid | |
| min_purchase_amount | numeric | |
| max_discount_amount | numeric | |
| is_combinable | boolean | |
| priority | integer | |
| created_at | timestamp with time zone | |

### Offer Articles (Table: offer_articles)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| offer_id | uuid | |
| article_id | uuid | |
| created_at | timestamp with time zone | |

## Price Management
### Price Configurations (Table: price_configurations)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| name | varchar | NOT NULL |
| description | text | |
| markup_percentage | numeric | |
| is_active | boolean | |
| created_at | timestamp with time zone | |

### Price History (Table: price_history)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| article_id | uuid | |
| base_price | numeric | |
| premium_price | numeric | |
| valid_from | timestamp with time zone | |
| valid_to | timestamp with time zone | |
| created_at | timestamp with time zone | |

## Order Management
### Order Items (Table: order_items)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| orderId | uuid | NOT NULL |
| articleId | uuid | NOT NULL |
| serviceId | uuid | NOT NULL |
| quantity | integer | NOT NULL |
| unitPrice | numeric | NOT NULL |
| createdAt | timestamp with time zone | NOT NULL |
| updatedAt | timestamp with time zone | NOT NULL |

### Orders Archive (Table: orders_archive)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| userId | uuid | |
| totalAmount | numeric | NOT NULL |
| status | varchar(50) | NOT NULL |
| address_id | uuid | |
| service_id | uuid | |
| service_type_id | uuid | |
| affiliatecode | varchar(255) | |
| isrecurring | boolean | |
| recurrencetype | varchar(50) | |
| collectiondate | timestamp with time zone | |
| deliverydate | timestamp with time zone | |
| nextrecurrencedate | timestamp with time zone | |
| createdAt | timestamp with time zone | |
| updatedat | timestamp with time zone | |
| archived_at | timestamp with time zone | |

## Categories
### Article Categories (Table: article_categories)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| name | varchar(100) | NOT NULL |
| description | text | |
| createdAt | timestamp with time zone | |

### Blog Categories (Table: blog_categories)
| Column Name | Type | Constraints |
|------------|------|-------------|
|------------|------|-------------|
| id | uuid | NOT NULL |
| name | varchar(100) | NOT NULL |
| description | text | |
| createdAt | timestamp with time zone | |

### Blog Categories (Table: blog_categories)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| name | varchar(255) | NOT NULL |
| description | text | |
| created_at | timestamp with time zone | |
| updated_at | timestamp with time zone | |

## Service Management
### Service Types (Table: service_types)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | PRIMARY KEY, NOT NULL |
| name | varchar(100) | NOT NULL, UNIQUE |
| description | text | |
| is_active | boolean | DEFAULT true |
| created_at | timestamp with time zone | |
| updated_at | timestamp with time zone | |

## Notifications
### Notification Rules (Table: notification_rules)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| event_type | varchar | NOT NULL |
| user_role | USER-DEFINED | NOT NULL |
| template | text | |
| is_active | boolean | |
| created_at | timestamp with time zone | |

### Notification Preferences (Table: notification_preferences)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
| user_id | uuid | NOT NULL |
| email | boolean | |
| sms | boolean | |
| push | boolean | |
| promotions | boolean | |
| order_updates | boolean | |
| payments | boolean | |
| loyalty | boolean | |
| created_at | timestamp with time zone | |
| updated_at | timestamp with time zone | |

## Security
### Reset Codes (Table: reset_codes)
| Column Name | Type | Constraints |
|------------|------|-------------|
| id | uuid | NOT NULL |
### OrderStatus
| user_id | uuid | NOT NULL |
| email | text | NOT NULL |
| code | varchar(6) | NOT NULL |
| expires_at | timestamp with time zone | NOT NULL |
| used | boolean | |
| created_at | timestamp with time zone | |
| updated_at | timestamp with time zone | |

[Note: Les autres tables ont été omises pour la clarté. Chaque section est organisée par domaine fonctionnel avec des tables connexes regroupées ensemble.]
- DRAFT (nouveau)
- PENDING
- COLLECTING
- COLLECTED
- PROCESSING
- READY
- DELIVERING
- DELIVERED
- CANCELLED

[Note: Les autres tables ont été omises pour la clarté. Chaque section est organisée par domaine fonctionnel avec des tables connexes regroupées ensemble.]