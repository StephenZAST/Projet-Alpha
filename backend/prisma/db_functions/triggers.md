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