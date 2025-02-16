


[
  {
    "trigger_name": "after_affiliate_earnings_update",
    "trigger_event": "UPDATE",
    "table_name": "affiliate_profiles",
    "trigger_definition": "EXECUTE FUNCTION trigger_update_affiliate_level()",
    "trigger_timing": "AFTER"
  },
  {
    "trigger_name": "archive_completed_orders_trigger",
    "trigger_event": "UPDATE",
    "table_name": "orders",
    "trigger_definition": "EXECUTE FUNCTION archive_completed_orders()",
    "trigger_timing": "AFTER"
  },
  {
    "trigger_name": "create_user_loyalty_points",
    "trigger_event": "INSERT",
    "table_name": "users",
    "trigger_definition": "EXECUTE FUNCTION initialize_user_loyalty_points()",
    "trigger_timing": "AFTER"
  },
  {
    "trigger_name": "flash_order_note_trigger",
    "trigger_event": "INSERT",
    "table_name": "orders",
    "trigger_definition": "EXECUTE FUNCTION insert_flash_order_note()",
    "trigger_timing": "AFTER"
  },
  {
    "trigger_name": "order_items_total_update",
    "trigger_event": "UPDATE",
    "table_name": "order_items",
    "trigger_definition": "EXECUTE FUNCTION update_order_total()",
    "trigger_timing": "AFTER"
  },
  {
    "trigger_name": "order_items_total_update",
    "trigger_event": "DELETE",
    "table_name": "order_items",
    "trigger_definition": "EXECUTE FUNCTION update_order_total()",
    "trigger_timing": "AFTER"
  },
  {
    "trigger_name": "order_items_total_update",
    "trigger_event": "INSERT",
    "table_name": "order_items",
    "trigger_definition": "EXECUTE FUNCTION update_order_total()",
    "trigger_timing": "AFTER"
  },
  {
    "trigger_name": "order_note_sync_trigger",
    "trigger_event": "INSERT",
    "table_name": "order_notes",
    "trigger_definition": "EXECUTE FUNCTION sync_order_note()",
    "trigger_timing": "AFTER"
  },
  {
    "trigger_name": "order_note_sync_trigger",
    "trigger_event": "UPDATE",
    "table_name": "order_notes",
    "trigger_definition": "EXECUTE FUNCTION sync_order_note()",
    "trigger_timing": "AFTER"
  },
  {
    "trigger_name": "set_timestamp",
    "trigger_event": "UPDATE",
    "table_name": "reset_codes",
    "trigger_definition": "EXECUTE FUNCTION trigger_set_timestamp()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_name": "set_updated_at",
    "trigger_event": "UPDATE",
    "table_name": "article_services",
    "trigger_definition": "EXECUTE FUNCTION update_timestamp_column('snake_case')",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_name": "update_article_service_compatibility_timestamp",
    "trigger_event": "UPDATE",
    "table_name": "article_service_compatibility",
    "trigger_definition": "EXECUTE FUNCTION update_service_timestamps()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_name": "update_articles_timestamp",
    "trigger_event": "UPDATE",
    "table_name": "articles",
    "trigger_definition": "EXECUTE FUNCTION update_timestamp_column('camelCase')",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_name": "update_loyalty_points_timestamp",
    "trigger_event": "UPDATE",
    "table_name": "loyalty_points",
    "trigger_definition": "EXECUTE FUNCTION update_loyalty_points_updated_at()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_name": "update_order_items_updated_at",
    "trigger_event": "UPDATE",
    "table_name": "order_items",
    "trigger_definition": "EXECUTE FUNCTION update_order_items_updated_at()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_name": "update_order_metadata_timestamp",
    "trigger_event": "UPDATE",
    "table_name": "order_metadata",
    "trigger_definition": "EXECUTE FUNCTION update_timestamp()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_name": "update_order_weights_updated_at",
    "trigger_event": "UPDATE",
    "table_name": "order_weights",
    "trigger_definition": "EXECUTE FUNCTION update_updated_at_column()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_name": "update_orders_updated_at",
    "trigger_event": "UPDATE",
    "table_name": "orders",
    "trigger_definition": "EXECUTE FUNCTION update_orders_timestamp()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_name": "update_service_specific_prices_timestamp",
    "trigger_event": "UPDATE",
    "table_name": "service_specific_prices",
    "trigger_definition": "EXECUTE FUNCTION update_service_timestamps()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_name": "update_service_types_timestamp",
    "trigger_event": "UPDATE",
    "table_name": "service_types",
    "trigger_definition": "EXECUTE FUNCTION update_timestamp_column()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_name": "update_subscription_plans_updated_at",
    "trigger_event": "UPDATE",
    "table_name": "subscription_plans",
    "trigger_definition": "EXECUTE FUNCTION update_updated_at_column()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_name": "update_user_subscriptions_updated_at",
    "trigger_event": "UPDATE",
    "table_name": "user_subscriptions",
    "trigger_definition": "EXECUTE FUNCTION update_updated_at_column()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_name": "update_weight_based_pricing_timestamp",
    "trigger_event": "UPDATE",
    "table_name": "weight_based_pricing",
    "trigger_definition": "EXECUTE FUNCTION update_timestamp_column()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_name": "validate_article_service_price_trigger",
    "trigger_event": "UPDATE",
    "table_name": "article_service_prices",
    "trigger_definition": "EXECUTE FUNCTION validate_article_service_price()",
    "trigger_timing": "BEFORE"
  },
  {
    "trigger_name": "validate_article_service_price_trigger",
    "trigger_event": "INSERT",
    "table_name": "article_service_prices",
    "trigger_definition": "EXECUTE FUNCTION validate_article_service_price()",
    "trigger_timing": "BEFORE"
  }
]