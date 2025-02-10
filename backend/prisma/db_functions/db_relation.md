# Database Relations

## User Management Relations
### User Related Relations
| Source Table | Source Column | Target Table | Target Column |
|-------------|---------------|--------------|---------------|
| addresses | user_id | users | id |
| notification_preferences | user_id | users | id |
| notifications | user_id | users | id |
| loyalty_points | user_id | users | id |
| reset_codes | user_id | users | id |
| reset_codes | email | users | email |

## Affiliate System Relations
### Affiliate Profile Relations
| Source Table | Source Column | Target Table | Target Column |
|-------------|---------------|--------------|---------------|
| affiliate_profiles | user_id | users | id |
| affiliate_profiles | level_id | affiliate_levels | id |
| affiliate_profiles | parent_affiliate_id | affiliate_profiles | id |
| commissionTransactions | affiliate_id | affiliate_profiles | id |
| commissionTransactions | order_id | orders | id |

## Article and Service Relations
### Article Relations
| Source Table | Source Column | Target Table | Target Column |
|-------------|---------------|--------------|---------------|
| articles | categoryId | article_categories | id |
| article_services | articleId | articles | id |
| article_services | serviceId | services | id |
| offer_articles | article_id | articles | id |
| price_history | article_id | articles | id |

## Order System Relations
### Order Related Relations
| Source Table | Source Column | Target Table | Target Column |
|-------------|---------------|--------------|---------------|
| orders | userId | users | id |
| orders | addressId | addresses | id |
| orders | serviceId | services | id |
| orders | service_type_id | service_types | id |
| order_items | orderId | orders | id |
| order_items | articleId | articles | id |
| order_items | serviceId | services | id |
| order_metadata | order_id | orders | id |

### Order Metadata Relations
| Source Table | Source Column | Target Table | Target Column |
|-------------|---------------|--------------|---------------|
| order_metadata | order_id | orders | id |

### Order Archive Relations
| Source Table | Source Column | Target Table | Target Column |
|-------------|---------------|--------------|---------------|
| orders_archive | id | orders | id |
| orders_archive | userId | users | id |
| orders_archive | address_id | addresses | id |
| orders_archive | service_id | services | id |
| orders_archive | service_type_id | service_types | id |

### Order Notes Relations
| Source Table | Source Column | Target Table | Target Column |
|-------------|---------------|--------------|---------------|
| order_notes | order_id | orders | id |

## Blog System Relations
### Blog Related Relations
| Source Table | Source Column | Target Table | Target Column |
|-------------|---------------|--------------|---------------|
| blog_articles | author_id | users | id |
| blog_articles | category_id | blog_categories | id |

## Offer and Discount Relations
### Offer Related Relations
| Source Table | Source Column | Target Table | Target Column |
|-------------|---------------|--------------|---------------|
| discount_rules | offer_id | offers | id |
| offer_articles | offer_id | offers | id |
| user_offers | offer_id | offers | id |
| user_offers | order_id | orders | id |
| user_offers | user_id | users | id |

## Reward System Relations
### Reward Related Relations
| Source Table | Source Column | Target Table | Target Column |
|-------------|---------------|--------------|---------------|
| reward_claims | reward_id | rewards | id |
| reward_claims | user_id | users | id |

## Transaction Relations
### Point Transaction Relations
| Source Table | Source Column | Target Table | Target Column |
|-------------|---------------|--------------|---------------|
| point_transactions | userId | users | id |



[
  {
    "table_schema": "public",
    "table_name": "blog_articles",
    "column_name": "author_id",
    "foreign_table_schema": "auth",
    "foreign_table_name": "users",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "blog_articles",
    "column_name": "category_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "blog_categories",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "order_items",
    "column_name": "articleId",
    "foreign_table_schema": "public",
    "foreign_table_name": "articles",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "order_items",
    "column_name": "orderId",
    "foreign_table_schema": "public",
    "foreign_table_name": "orders",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "order_items",
    "column_name": "serviceId",
    "foreign_table_schema": "public",
    "foreign_table_name": "services",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "article_archives",
    "column_name": "original_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "articles",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "price_history",
    "column_name": "article_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "articles",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "reset_codes",
    "column_name": "email",
    "foreign_table_schema": "public",
    "foreign_table_name": "users",
    "foreign_column_name": "email"
  },
  {
    "table_schema": "public",
    "table_name": "reset_codes",
    "column_name": "user_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "users",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "order_metadata",
    "column_name": "order_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "orders",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "affiliate_profiles",
    "column_name": "level_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "affiliate_levels",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "affiliate_profiles",
    "column_name": "parent_affiliate_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "affiliate_profiles",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "affiliate_profiles",
    "column_name": "user_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "users",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "discount_rules",
    "column_name": "offer_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "offers",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "order_notes",
    "column_name": "order_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "orders",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "commissionTransactions",
    "column_name": "affiliate_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "affiliate_profiles",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "commissionTransactions",
    "column_name": "order_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "orders",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "notification_preferences",
    "column_name": "user_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "users",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "orders_archive",
    "column_name": "address_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "addresses",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "orders_archive",
    "column_name": "id",
    "foreign_table_schema": "public",
    "foreign_table_name": "orders",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "orders_archive",
    "column_name": "service_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "services",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "orders_archive",
    "column_name": "service_type_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "service_types",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "orders_archive",
    "column_name": "userId",
    "foreign_table_schema": "public",
    "foreign_table_name": "users",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "loyalty_points",
    "column_name": "user_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "users",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "point_transactions",
    "column_name": "userId",
    "foreign_table_schema": "public",
    "foreign_table_name": "users",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "reward_claims",
    "column_name": "reward_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "rewards",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "reward_claims",
    "column_name": "user_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "users",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "notifications",
    "column_name": "user_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "users",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "article_services",
    "column_name": "articleId",
    "foreign_table_schema": "public",
    "foreign_table_name": "articles",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "article_services",
    "column_name": "serviceId",
    "foreign_table_schema": "public",
    "foreign_table_name": "services",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "addresses",
    "column_name": "user_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "users",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "user_offers",
    "column_name": "offer_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "offers",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "user_offers",
    "column_name": "order_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "orders",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "user_offers",
    "column_name": "user_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "users",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "offer_articles",
    "column_name": "article_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "articles",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "offer_articles",
    "column_name": "offer_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "offers",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "articles",
    "column_name": "categoryId",
    "foreign_table_schema": "public",
    "foreign_table_name": "article_categories",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "orders",
    "column_name": "addressId",
    "foreign_table_schema": "public",
    "foreign_table_name": "addresses",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "orders",
    "column_name": "serviceId",
    "foreign_table_schema": "public",
    "foreign_table_name": "services",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "orders",
    "column_name": "service_type_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "service_types",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "orders",
    "column_name": "userId",
    "foreign_table_schema": "public",
    "foreign_table_name": "users",
    "foreign_column_name": "id"
  }
]