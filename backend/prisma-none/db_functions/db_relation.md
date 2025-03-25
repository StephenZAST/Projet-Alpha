[
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
    "table_name": "addresses",
    "column_name": "user_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "users",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "article_services",
    "column_name": "article_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "articles",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "article_services",
    "column_name": "service_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "services",
    "foreign_column_name": "id"
  },
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
    "table_name": "discount_rules",
    "column_name": "offer_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "offers",
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
    "table_name": "point_transactions",
    "column_name": "userId",
    "foreign_table_schema": "public",
    "foreign_table_name": "users",
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
    "table_name": "notifications",
    "column_name": "user_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "users",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "user_subscriptions",
    "column_name": "plan_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "subscription_plans",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "user_subscriptions",
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
    "table_name": "services",
    "column_name": "service_type_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "service_types",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "article_service_prices",
    "column_name": "article_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "articles",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "article_service_prices",
    "column_name": "service_type_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "service_types",
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
    "table_name": "article_service_compatibility",
    "column_name": "article_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "articles",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "article_service_compatibility",
    "column_name": "service_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "services",
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
    "table_name": "loyalty_points",
    "column_name": "user_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "users",
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
    "table_name": "offer_subscriptions",
    "column_name": "offer_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "offers",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "offer_subscriptions",
    "column_name": "user_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "users",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "order_weights",
    "column_name": "order_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "orders",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "order_weights",
    "column_name": "verified_by",
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
    "table_name": "service_specific_prices",
    "column_name": "article_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "articles",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "service_specific_prices",
    "column_name": "service_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "services",
    "foreign_column_name": "id"
  },
  {
    "table_schema": "public",
    "table_name": "weight_based_pricing",
    "column_name": "service_type_id",
    "foreign_table_schema": "public",
    "foreign_table_name": "service_types",
    "foreign_column_name": "id"
  }
]