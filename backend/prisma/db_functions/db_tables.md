[
  {
    "table_schema": "public",
    "table_name": "addresses",
    "columns": "name character varying(255)\nuser_id uuid\nid uuid NOT NULL\nstreet character varying(255) NOT NULL\ncity character varying(100) NOT NULL\npostal_code character varying(20)\ngps_latitude numeric\ngps_longitude numeric\nis_default boolean\ncreated_at timestamp with time zone\nupdated_at timestamp with time zone"
  },
  {
    "table_schema": "public",
    "table_name": "affiliate_levels",
    "columns": "id uuid NOT NULL\nupdated_at timestamp with time zone\ncreated_at timestamp with time zone\ncommissionRate numeric NOT NULL\nminEarnings numeric NOT NULL\nname character varying(50) NOT NULL"
  },
  {
    "table_schema": "public",
    "table_name": "affiliate_profiles",
    "columns": "created_at timestamp with time zone\ntotal_earned numeric\ncommission_balance numeric\nlevel_id uuid\nmonthly_earnings numeric\nparent_affiliate_id uuid\naffiliate_code character varying(255) NOT NULL\nuser_id uuid NOT NULL\nid uuid NOT NULL\ntotal_referrals integer\nis_active boolean\nstatus USER-DEFINED\ncommission_rate numeric\nupdated_at timestamp with time zone"
  },
  {
    "table_schema": "public",
    "table_name": "article_categories",
    "columns": "name character varying(100) NOT NULL\ndescription text\ncreatedAt timestamp with time zone\nid uuid NOT NULL"
  },
  {
    "table_schema": "public",
    "table_name": "article_services",
    "columns": "serviceId uuid\narticleId uuid\nid uuid NOT NULL\npriceMultiplier numeric NOT NULL\ncreatedAt timestamp with time zone"
  },
  {
    "table_schema": "public",
    "table_name": "articles",
    "columns": "description text\npremiumPrice numeric\nupdatedAt timestamp with time zone\ncreatedAt timestamp with time zone\nbasePrice numeric NOT NULL\nname character varying(255) NOT NULL\ncategoryId uuid\nid uuid NOT NULL"
  },
  {
    "table_schema": "public",
    "table_name": "blog_articles",
    "columns": "is_published boolean\ntitle character varying(255) NOT NULL\ncontent text NOT NULL\ncategory_id uuid\nauthor_id uuid NOT NULL\nid uuid NOT NULL\ncreated_at timestamp with time zone\nupdated_at timestamp with time zone\npublished_at timestamp with time zone"
  },
  {
    "table_schema": "public",
    "table_name": "blog_categories",
    "columns": "description text\nid uuid NOT NULL\nupdated_at timestamp with time zone\ncreated_at timestamp with time zone\nname character varying(255) NOT NULL"
  },
  {
    "table_schema": "public",
    "table_name": "commissionTransactions",
    "columns": "order_id uuid NOT NULL\nid uuid NOT NULL\naffiliate_id uuid\namount numeric NOT NULL\ncreated_at timestamp with time zone\nstatus USER-DEFINED NOT NULL"
  },
  {
    "table_schema": "public",
    "table_name": "discount_rules",
    "columns": "created_at timestamp with time zone\npriority integer\nmin_purchase_amount numeric\nid uuid NOT NULL\nmax_discount_amount numeric\noffer_id uuid\nis_combinable boolean"
  },
  {
    "table_schema": "public",
    "table_name": "loyalty_points",
    "columns": "pointsBalance integer\nid uuid NOT NULL\nupdatedAt timestamp with time zone\ncreatedAt timestamp with time zone\ntotalEarned integer\nuser_id uuid"
  },
  {
    "table_schema": "public",
    "table_name": "notification_preferences",
    "columns": "promotions boolean\nuser_id uuid NOT NULL\nemail boolean\npush boolean\nsms boolean\norder_updates boolean\nupdated_at timestamp with time zone\ncreated_at timestamp with time zone\nloyalty boolean\npayments boolean\nid uuid NOT NULL"
  },
  {
    "table_schema": "public",
    "table_name": "notification_rules",
    "columns": "event_type character varying NOT NULL\nid uuid NOT NULL\nuser_role USER-DEFINED NOT NULL\ntemplate text\nis_active boolean\ncreated_at timestamp with time zone"
  },
  {
    "table_schema": "public",
    "table_name": "notifications",
    "columns": "user_id uuid\ntype USER-DEFINED NOT NULL\nmessage text NOT NULL\nread boolean\ncreated_at timestamp with time zone\nid uuid NOT NULL\nupdated_at timestamp with time zone"
  },
  {
    "table_schema": "public",
    "table_name": "offer_articles",
    "columns": "id uuid NOT NULL\narticle_id uuid\noffer_id uuid\ncreated_at timestamp with time zone"
  },
  {
    "table_schema": "public",
    "table_name": "offers",
    "columns": "isCumulative boolean\nid uuid NOT NULL\nname character varying(255) NOT NULL\ndescription text\ndiscountType character varying(20) NOT NULL\ndiscountValue numeric NOT NULL\nminPurchaseAmount numeric\nmaxDiscountAmount numeric\npoints_required integer\nstartDate timestamp with time zone\nendDate timestamp with time zone\nis_active boolean\ncreated_at timestamp with time zone\nupdated_at timestamp with time zone\npointsRequired numeric"
  },
  {
    "table_schema": "public",
    "table_name": "order_items",
    "columns": "unitPrice numeric NOT NULL\ncreatedAt timestamp with time zone NOT NULL\nupdatedAt timestamp with time zone NOT NULL\nid uuid NOT NULL\norderId uuid NOT NULL\narticleId uuid NOT NULL\nserviceId uuid NOT NULL\nquantity integer NOT NULL"
  },
  {
    "table_schema": "public",
    "table_name": "orders",
    "columns": "createdAt timestamp with time zone\ndeliveryDate timestamp with time zone\ncollectionDate timestamp with time zone\ntotalAmount numeric\nnextRecurrenceDate timestamp with time zone\nrecurrenceType USER-DEFINED\naddressId uuid\nstatus USER-DEFINED\nisRecurring boolean\naffiliateCode text\nid uuid NOT NULL\npaymentMethod USER-DEFINED\nuserId uuid NOT NULL\nservice_type_id uuid\nserviceId uuid\nupdatedAt timestamp with time zone"
  },
  {
    "table_schema": "public",
    "table_name": "orders_archive",
    "columns": "affiliatecode character varying(255)\nid uuid NOT NULL\ntotalAmount numeric NOT NULL\ncollectiondate timestamp with time zone\ndeliverydate timestamp with time zone\ncreatedAt timestamp with time zone\nupdatedat timestamp with time zone\nservice_id uuid\nservice_type_id uuid\nuserId uuid\narchived_at timestamp with time zone\nnextrecurrencedate timestamp with time zone\nrecurrencetype character varying(50)\nisrecurring boolean\nstatus character varying(50) NOT NULL\naddress_id uuid"
  },
  {
    "table_schema": "public",
    "table_name": "point_transactions",
    "columns": "id uuid NOT NULL\nrelated_transaction_id uuid\nreferenceId character varying(255) NOT NULL\nsource USER-DEFINED NOT NULL\ntype USER-DEFINED NOT NULL\npoints integer\ncreatedAt timestamp with time zone\nconversion_rate numeric\nuserId uuid"
  },
  {
    "table_schema": "public",
    "table_name": "price_configurations",
    "columns": "is_active boolean\ncreated_at timestamp with time zone\nid uuid NOT NULL\nname character varying NOT NULL\ndescription text\nmarkup_percentage numeric"
  },
  {
    "table_schema": "public",
    "table_name": "price_history",
    "columns": "premium_price numeric\nbase_price numeric\narticle_id uuid\nid uuid NOT NULL\ncreated_at timestamp with time zone\nvalid_to timestamp with time zone\nvalid_from timestamp with time zone"
  },
  {
    "table_schema": "public",
    "table_name": "reset_codes",
    "columns": "updated_at timestamp with time zone\nuser_id uuid NOT NULL\nid uuid NOT NULL\nexpires_at timestamp with time zone NOT NULL\nemail text NOT NULL\ncode character varying(6) NOT NULL\nused boolean\ncreated_at timestamp with time zone"
  },
  {
    "table_schema": "public",
    "table_name": "reward_claims",
    "columns": "points_spent integer NOT NULL\nreward_id uuid\ncreated_at timestamp with time zone\nid uuid NOT NULL\nuser_id uuid"
  },
  {
    "table_schema": "public",
    "table_name": "rewards",
    "columns": "id uuid NOT NULL\nupdated_at timestamp with time zone\ncreated_at timestamp with time zone\navailable boolean\npoints_cost integer NOT NULL\ndescription text\nname character varying(255) NOT NULL"
  },
  {
    "table_schema": "public",
    "table_name": "service_types",
    "columns": "name character varying(100) NOT NULL\ndescription text\ncreated_at timestamp with time zone\nid uuid NOT NULL"
  },
  {
    "table_schema": "public",
    "table_name": "services",
    "columns": "id uuid NOT NULL\nname character varying(100) NOT NULL\ndescription text\ncreated_at timestamp with time zone\nupdated_at timestamp with time zone\nprice integer"
  },
  {
    "table_schema": "public",
    "table_name": "user_offers",
    "columns": "offer_id uuid\nuser_id uuid\nid uuid NOT NULL\npoints_spent integer\norder_id uuid\nused_at timestamp with time zone\ncreated_at timestamp with time zone"
  },
  {
    "table_schema": "public",
    "table_name": "users",
    "columns": "referral_code character varying(20)\nrole USER-DEFINED\nphone character varying(20)\nlast_name character varying(100) NOT NULL\nfirst_name character varying(100) NOT NULL\npassword character varying(255) NOT NULL\nemail character varying(255) NOT NULL\nid uuid NOT NULL\nupdated_at timestamp with time zone\ncreated_at timestamp with time zone"
  }
]