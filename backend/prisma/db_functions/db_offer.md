[
  {
    "column_name": "id",
    "data_type": "uuid",
    "character_maximum_length": null,
    "column_default": "uuid_generate_v4()",
    "is_nullable": "NO"
  },
  {
    "column_name": "name",
    "data_type": "character varying",
    "character_maximum_length": 255,
    "column_default": null,
    "is_nullable": "NO"
  },
  {
    "column_name": "description",
    "data_type": "text",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "YES"
  },
  {
    "column_name": "discountType",
    "data_type": "character varying",
    "character_maximum_length": 20,
    "column_default": null,
    "is_nullable": "NO"
  },
  {
    "column_name": "discountValue",
    "data_type": "numeric",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "NO"
  },
  {
    "column_name": "minPurchaseAmount",
    "data_type": "numeric",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "YES"
  },
  {
    "column_name": "maxDiscountAmount",
    "data_type": "numeric",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "YES"
  },
  {
    "column_name": "isCumulative",
    "data_type": "boolean",
    "character_maximum_length": null,
    "column_default": "false",
    "is_nullable": "YES"
  },
  {
    "column_name": "startDate",
    "data_type": "timestamp with time zone",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "YES"
  },
  {
    "column_name": "endDate",
    "data_type": "timestamp with time zone",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "YES"
  },
  {
    "column_name": "is_active",
    "data_type": "boolean",
    "character_maximum_length": null,
    "column_default": "true",
    "is_nullable": "YES"
  },
  {
    "column_name": "created_at",
    "data_type": "timestamp with time zone",
    "character_maximum_length": null,
    "column_default": "now()",
    "is_nullable": "YES"
  },
  {
    "column_name": "updated_at",
    "data_type": "timestamp with time zone",
    "character_maximum_length": null,
    "column_default": "now()",
    "is_nullable": "YES"
  },
  {
    "column_name": "pointsRequired",
    "data_type": "numeric",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "YES"
  }
]



[
  {
    "column_name": "id",
    "data_type": "uuid",
    "character_maximum_length": null,
    "column_default": "uuid_generate_v4()",
    "is_nullable": "NO"
  },
  {
    "column_name": "user_id",
    "data_type": "uuid",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "YES"
  },
  {
    "column_name": "offer_id",
    "data_type": "uuid",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "YES"
  },
  {
    "column_name": "status",
    "data_type": "USER-DEFINED",
    "character_maximum_length": null,
    "column_default": "'ACTIVE'::offer_status_enum",
    "is_nullable": "YES"
  },
  {
    "column_name": "subscribed_at",
    "data_type": "timestamp with time zone",
    "character_maximum_length": null,
    "column_default": "CURRENT_TIMESTAMP",
    "is_nullable": "YES"
  },
  {
    "column_name": "updated_at",
    "data_type": "timestamp with time zone",
    "character_maximum_length": null,
    "column_default": "CURRENT_TIMESTAMP",
    "is_nullable": "YES"
  }
]




  