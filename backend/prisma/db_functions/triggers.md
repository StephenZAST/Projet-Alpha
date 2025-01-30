[
  {
    "trigger_schema": "pgsodium",
    "trigger_name": "key_encrypt_secret_trigger_raw_key",
    "trigger_event": "INSERT",
    "table_schema": "pgsodium",
    "table_name": "key",
    "trigger_definition": "EXECUTE FUNCTION pgsodium.key_encrypt_secret_raw_key()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_schema": "pgsodium",
    "trigger_name": "key_encrypt_secret_trigger_raw_key",
    "trigger_event": "UPDATE",
    "table_schema": "pgsodium",
    "table_name": "key",
    "trigger_definition": "EXECUTE FUNCTION pgsodium.key_encrypt_secret_raw_key()",
    "trigger_timing": "BEFORE"
  },
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
  },
  {
    "trigger_schema": "realtime",
    "trigger_name": "tr_check_filters",
    "trigger_event": "INSERT",
    "table_schema": "realtime",
    "table_name": "subscription",
    "trigger_definition": "EXECUTE FUNCTION realtime.subscription_check_filters()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_schema": "realtime",
    "trigger_name": "tr_check_filters",
    "trigger_event": "UPDATE",
    "table_schema": "realtime",
    "table_name": "subscription",
    "trigger_definition": "EXECUTE FUNCTION realtime.subscription_check_filters()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_schema": "storage",
    "trigger_name": "update_objects_updated_at",
    "trigger_event": "UPDATE",
    "table_schema": "storage",
    "table_name": "objects",
    "trigger_definition": "EXECUTE FUNCTION storage.update_updated_at_column()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_schema": "vault",
    "trigger_name": "secrets_encrypt_secret_trigger_secret",
    "trigger_event": "INSERT",
    "table_schema": "vault",
    "table_name": "secrets",
    "trigger_definition": "EXECUTE FUNCTION vault.secrets_encrypt_secret_secret()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_schema": "vault",
    "trigger_name": "secrets_encrypt_secret_trigger_secret",
    "trigger_event": "UPDATE",
    "table_schema": "vault",
    "table_name": "secrets",
    "trigger_definition": "EXECUTE FUNCTION vault.secrets_encrypt_secret_secret()",
    "trigger_timing": "BEFORE"
  }
]