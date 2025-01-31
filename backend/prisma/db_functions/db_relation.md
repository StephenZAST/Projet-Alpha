[
  {
    "source_table": "addresses",
    "source_column": "user_id",
    "target_table": "users",
    "target_column": "id"
  },
  {
    "source_table": "affiliate_profiles",
    "source_column": "level_id",
    "target_table": "affiliate_levels",
    "target_column": "id"
  },
  {
    "source_table": "affiliate_profiles",
    "source_column": "parent_affiliate_id",
    "target_table": "affiliate_profiles",
    "target_column": "id"
  },
  {
    "source_table": "affiliate_profiles",
    "source_column": "user_id",
    "target_table": "users",
    "target_column": "id"
  },
  {
    "source_table": "article_services",
    "source_column": "articleId",
    "target_table": "articles",
    "target_column": "id"
  },
  {
    "source_table": "article_services",
    "source_column": "serviceId",
    "target_table": "services",
    "target_column": "id"
  },
  {
    "source_table": "articles",
    "source_column": "categoryId",
    "target_table": "article_categories",
    "target_column": "id"
  },
  {
    "source_table": "blog_articles",
    "source_column": "author_id",
    "target_table": "users",
    "target_column": "id"
  },
  {
    "source_table": "blog_articles",
    "source_column": "category_id",
    "target_table": "blog_categories",
    "target_column": "id"
  },
  {
    "source_table": "commissionTransactions",
    "source_column": "affiliate_id",
    "target_table": "affiliate_profiles",
    "target_column": "id"
  },
  {
    "source_table": "commissionTransactions",
    "source_column": "order_id",
    "target_table": "orders",
    "target_column": "id"
  },
  {
    "source_table": "discount_rules",
    "source_column": "offer_id",
    "target_table": "offers",
    "target_column": "id"
  },
  {
    "source_table": "loyalty_points",
    "source_column": "user_id",
    "target_table": "users",
    "target_column": "id"
  },
  {
    "source_table": "notification_preferences",
    "source_column": "user_id",
    "target_table": "users",
    "target_column": "id"
  },
  {
    "source_table": "notifications",
    "source_column": "user_id",
    "target_table": "users",
    "target_column": "id"
  },
  {
    "source_table": "offer_articles",
    "source_column": "article_id",
    "target_table": "articles",
    "target_column": "id"
  },
  {
    "source_table": "offer_articles",
    "source_column": "offer_id",
    "target_table": "offers",
    "target_column": "id"
  },
  {
    "source_table": "order_items",
    "source_column": "articleId",
    "target_table": "articles",
    "target_column": "id"
  },
  {
    "source_table": "order_items",
    "source_column": "orderId",
    "target_table": "orders",
    "target_column": "id"
  },
  {
    "source_table": "order_items",
    "source_column": "serviceId",
    "target_table": "services",
    "target_column": "id"
  },
  {
    "source_table": "orders",
    "source_column": "addressId",
    "target_table": "addresses",
    "target_column": "id"
  },
  {
    "source_table": "orders",
    "source_column": "serviceId",
    "target_table": "services",
    "target_column": "id"
  },
  {
    "source_table": "orders",
    "source_column": "service_type_id",
    "target_table": "service_types",
    "target_column": "id"
  },
  {
    "source_table": "orders",
    "source_column": "userId",
    "target_table": "users",
    "target_column": "id"
  },
  {
    "source_table": "orders_archive",
    "source_column": "address_id",
    "target_table": "addresses",
    "target_column": "id"
  },
  {
    "source_table": "orders_archive",
    "source_column": "id",
    "target_table": "orders",
    "target_column": "id"
  },
  {
    "source_table": "orders_archive",
    "source_column": "service_id",
    "target_table": "services",
    "target_column": "id"
  },
  {
    "source_table": "orders_archive",
    "source_column": "service_type_id",
    "target_table": "service_types",
    "target_column": "id"
  },
  {
    "source_table": "orders_archive",
    "source_column": "userId",
    "target_table": "users",
    "target_column": "id"
  },
  {
    "source_table": "point_transactions",
    "source_column": "userId",
    "target_table": "users",
    "target_column": "id"
  },
  {
    "source_table": "price_history",
    "source_column": "article_id",
    "target_table": "articles",
    "target_column": "id"
  },
  {
    "source_table": "reset_codes",
    "source_column": "email",
    "target_table": "users",
    "target_column": "email"
  },
  {
    "source_table": "reset_codes",
    "source_column": "user_id",
    "target_table": "users",
    "target_column": "id"
  },
  {
    "source_table": "reward_claims",
    "source_column": "reward_id",
    "target_table": "rewards",
    "target_column": "id"
  },
  {
    "source_table": "reward_claims",
    "source_column": "user_id",
    "target_table": "users",
    "target_column": "id"
  },
  {
    "source_table": "user_offers",
    "source_column": "offer_id",
    "target_table": "offers",
    "target_column": "id"
  },
  {
    "source_table": "user_offers",
    "source_column": "order_id",
    "target_table": "orders",
    "target_column": "id"
  },
  {
    "source_table": "user_offers",
    "source_column": "user_id",
    "target_table": "users",
    "target_column": "id"
  }
]