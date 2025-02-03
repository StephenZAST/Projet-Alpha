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