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
    "column_name": "type",
    "data_type": "USER-DEFINED",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "NO"
  },
  {
    "column_name": "message",
    "data_type": "text",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "NO"
  },
  {
    "column_name": "read",
    "data_type": "boolean",
    "character_maximum_length": null,
    "column_default": "false",
    "is_nullable": "YES"
  },
  {
    "column_name": "created_at",
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
  },
  {
    "column_name": "data",
    "data_type": "jsonb",
    "character_maximum_length": null,
    "column_default": null,
    "is_nullable": "YES"
  }
]



relation 


[
  {
    "source_table": "notifications",
    "source_column": "user_id",
    "target_table": "users",
    "target_column": "id"
  }
]