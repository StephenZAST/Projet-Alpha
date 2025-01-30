[
  {
    "trigger_schema": "public",
    "trigger_name": "after_affiliate_earnings_update",
    "trigger_event": "UPDATE",
    "table_schema": "public",
    "table_name": "affiliate_profiles",
    "trigger_definition": "EXECUTE FUNCTION trigger_update_affiliate_level()",
    "trigger_timing": "AFTER"
  },
  {
    "trigger_schema": "public",
    "trigger_name": "archive_completed_orders_trigger",
    "trigger_event": "UPDATE",
    "table_schema": "public",
    "table_name": "orders",
    "trigger_definition": "EXECUTE FUNCTION archive_completed_orders()",
    "trigger_timing": "AFTER"
  },
  {
    "trigger_schema": "public",
    "trigger_name": "create_user_loyalty_points",
    "trigger_event": "INSERT",
    "table_schema": "public",
    "table_name": "users",
    "trigger_definition": "EXECUTE FUNCTION initialize_user_loyalty_points()",
    "trigger_timing": "AFTER"
  },
  {
    "trigger_schema": "public",
    "trigger_name": "set_timestamp",
    "trigger_event": "UPDATE",
    "table_schema": "public",
    "table_name": "reset_codes",
    "trigger_definition": "EXECUTE FUNCTION trigger_set_timestamp()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_schema": "public",
    "trigger_name": "update_addresses_updated_at",
    "trigger_event": "UPDATE",
    "table_schema": "public",
    "table_name": "addresses",
    "trigger_definition": "EXECUTE FUNCTION update_updated_at_column()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_schema": "public",
    "trigger_name": "update_articles_updated_at",
    "trigger_event": "UPDATE",
    "table_schema": "public",
    "table_name": "articles",
    "trigger_definition": "EXECUTE FUNCTION update_updated_at_column()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_schema": "public",
    "trigger_name": "update_blog_articles_updated_at",
    "trigger_event": "UPDATE",
    "table_schema": "public",
    "table_name": "blog_articles",
    "trigger_definition": "EXECUTE FUNCTION update_updated_at_column()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_schema": "public",
    "trigger_name": "update_blog_categories_updated_at",
    "trigger_event": "UPDATE",
    "table_schema": "public",
    "table_name": "blog_categories",
    "trigger_definition": "EXECUTE FUNCTION update_updated_at_column()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_schema": "public",
    "trigger_name": "update_loyalty_points_timestamp",
    "trigger_event": "UPDATE",
    "table_schema": "public",
    "table_name": "loyalty_points",
    "trigger_definition": "EXECUTE FUNCTION update_loyalty_points_updated_at()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_schema": "public",
    "trigger_name": "update_notifications_updated_at",
    "trigger_event": "UPDATE",
    "table_schema": "public",
    "table_name": "notifications",
    "trigger_definition": "EXECUTE FUNCTION update_updated_at_column()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_schema": "public",
    "trigger_name": "update_order_items_updated_at",
    "trigger_event": "UPDATE",
    "table_schema": "public",
    "table_name": "order_items",
    "trigger_definition": "EXECUTE FUNCTION update_order_items_updated_at()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_schema": "public",
    "trigger_name": "update_orders_updated_at",
    "trigger_event": "UPDATE",
    "table_schema": "public",
    "table_name": "orders",
    "trigger_definition": "EXECUTE FUNCTION update_orders_timestamp()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_schema": "public",
    "trigger_name": "update_services_updated_at",
    "trigger_event": "UPDATE",
    "table_schema": "public",
    "table_name": "services",
    "trigger_definition": "EXECUTE FUNCTION update_updated_at_column()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_schema": "public",
    "trigger_name": "update_users_updated_at",
    "trigger_event": "UPDATE",
    "table_schema": "public",
    "table_name": "users",
    "trigger_definition": "EXECUTE FUNCTION update_updated_at_column()",
    "trigger_timing": "BEFORE"
  }
]