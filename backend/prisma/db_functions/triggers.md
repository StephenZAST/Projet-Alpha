# Database Triggers

## Automatic Timestamps
### Update Timestamp Triggers
| Trigger Name | Table | Event | Timing | Description |
|-------------|--------|-------|---------|-------------|
| update_addresses_updated_at | addresses | UPDATE | BEFORE | Met à jour le timestamp de modification |
| update_articles_updated_at | articles | UPDATE | BEFORE | Met à jour le timestamp de modification |
| update_blog_articles_updated_at | blog_articles | UPDATE | BEFORE | Met à jour le timestamp de modification |
| update_blog_categories_updated_at | blog_categories | UPDATE | BEFORE | Met à jour le timestamp de modification |
| update_notifications_updated_at | notifications | UPDATE | BEFORE | Met à jour le timestamp de modification |
| update_services_updated_at | services | UPDATE | BEFORE | Met à jour le timestamp de modification |
| update_users_updated_at | users | UPDATE | BEFORE | Met à jour le timestamp de modification |
| set_timestamp | reset_codes | UPDATE | BEFORE | Met à jour le timestamp des codes de réinitialisation |

## Order Management
### Order Related Triggers
| Trigger Name | Table | Event | Timing | Description |
|-------------|--------|-------|---------|-------------|
| archive_completed_orders_trigger | orders | UPDATE | AFTER | Archive automatiquement les commandes terminées |
| update_orders_updated_at | orders | UPDATE | BEFORE | Met à jour le timestamp des commandes |
| update_order_items_updated_at | order_items | UPDATE | BEFORE | Met à jour le timestamp des articles commandés |

## User Management
### User Related Triggers
| Trigger Name | Table | Event | Timing | Description |
|-------------|--------|-------|---------|-------------|
| create_user_loyalty_points | users | INSERT | AFTER | Initialise les points de fidélité pour les nouveaux utilisateurs |
| update_loyalty_points_timestamp | loyalty_points | UPDATE | BEFORE | Met à jour le timestamp des points de fidélité |

## Affiliate System
### Affiliate Related Triggers
| Trigger Name | Table | Event | Timing | Description |
|-------------|--------|-------|---------|-------------|
| after_affiliate_earnings_update | affiliate_profiles | UPDATE | AFTER | Met à jour le niveau d'affilié basé sur les gains |



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
    "trigger_name": "order_note_sync_trigger",
    "trigger_event": "UPDATE",
    "table_name": "order_notes",
    "trigger_definition": "EXECUTE FUNCTION sync_order_note()",
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
    "trigger_name": "update_orders_updated_at",
    "trigger_event": "UPDATE",
    "table_name": "orders",
    "trigger_definition": "EXECUTE FUNCTION update_orders_timestamp()",
    "trigger_timing": "BEFORE"
  }
]