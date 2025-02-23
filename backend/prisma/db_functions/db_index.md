[ 
  {
    "schema_name": "auth",
    "table_name": "audit_log_entries",
    "index_name": "audit_log_entries_pkey",
    "index_definition": "CREATE UNIQUE INDEX audit_log_entries_pkey ON auth.audit_log_entries USING btree (id)"
  },
  {
    "schema_name": "auth",
    "table_name": "audit_log_entries",
    "index_name": "audit_logs_instance_id_idx",
    "index_definition": "CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id)"
  },
  {
    "schema_name": "auth",
    "table_name": "flow_state",
    "index_name": "flow_state_created_at_idx",
    "index_definition": "CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC)"
  },
  {
    "schema_name": "auth",
    "table_name": "flow_state",
    "index_name": "flow_state_pkey",
    "index_definition": "CREATE UNIQUE INDEX flow_state_pkey ON auth.flow_state USING btree (id)"
  },
  {
    "schema_name": "auth",
    "table_name": "flow_state",
    "index_name": "idx_auth_code",
    "index_definition": "CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code)"
  },
  {
    "schema_name": "auth",
    "table_name": "flow_state",
    "index_name": "idx_user_id_auth_method",
    "index_definition": "CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method)"
  },
  {
    "schema_name": "auth",
    "table_name": "identities",
    "index_name": "identities_email_idx",
    "index_definition": "CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops)"
  },
  {
    "schema_name": "auth",
    "table_name": "identities",
    "index_name": "identities_pkey",
    "index_definition": "CREATE UNIQUE INDEX identities_pkey ON auth.identities USING btree (id)"
  },
  {
    "schema_name": "auth",
    "table_name": "identities",
    "index_name": "identities_provider_id_provider_unique",
    "index_definition": "CREATE UNIQUE INDEX identities_provider_id_provider_unique ON auth.identities USING btree (provider_id, provider)"
  },
  {
    "schema_name": "auth",
    "table_name": "identities",
    "index_name": "identities_user_id_idx",
    "index_definition": "CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id)"
  },
  {
    "schema_name": "auth",
    "table_name": "instances",
    "index_name": "instances_pkey",
    "index_definition": "CREATE UNIQUE INDEX instances_pkey ON auth.instances USING btree (id)"
  },
  {
    "schema_name": "auth",
    "table_name": "mfa_amr_claims",
    "index_name": "amr_id_pk",
    "index_definition": "CREATE UNIQUE INDEX amr_id_pk ON auth.mfa_amr_claims USING btree (id)"
  },
  {
    "schema_name": "auth",
    "table_name": "mfa_amr_claims",
    "index_name": "mfa_amr_claims_session_id_authentication_method_pkey",
    "index_definition": "CREATE UNIQUE INDEX mfa_amr_claims_session_id_authentication_method_pkey ON auth.mfa_amr_claims USING btree (session_id, authentication_method)"
  },
  {
    "schema_name": "auth",
    "table_name": "mfa_challenges",
    "index_name": "mfa_challenge_created_at_idx",
    "index_definition": "CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC)"
  },
  {
    "schema_name": "auth",
    "table_name": "mfa_challenges",
    "index_name": "mfa_challenges_pkey",
    "index_definition": "CREATE UNIQUE INDEX mfa_challenges_pkey ON auth.mfa_challenges USING btree (id)"
  },
  {
    "schema_name": "auth",
    "table_name": "mfa_factors",
    "index_name": "factor_id_created_at_idx",
    "index_definition": "CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at)"
  },
  {
    "schema_name": "auth",
    "table_name": "mfa_factors",
    "index_name": "mfa_factors_last_challenged_at_key",
    "index_definition": "CREATE UNIQUE INDEX mfa_factors_last_challenged_at_key ON auth.mfa_factors USING btree (last_challenged_at)"
  },
  {
    "schema_name": "auth",
    "table_name": "mfa_factors",
    "index_name": "mfa_factors_pkey",
    "index_definition": "CREATE UNIQUE INDEX mfa_factors_pkey ON auth.mfa_factors USING btree (id)"
  },
  {
    "schema_name": "auth",
    "table_name": "mfa_factors",
    "index_name": "mfa_factors_user_friendly_name_unique",
    "index_definition": "CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text)"
  },
  {
    "schema_name": "auth",
    "table_name": "mfa_factors",
    "index_name": "mfa_factors_user_id_idx",
    "index_definition": "CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id)"
  },
  {
    "schema_name": "auth",
    "table_name": "mfa_factors",
    "index_name": "unique_phone_factor_per_user",
    "index_definition": "CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone)"
  },
  {
    "schema_name": "auth",
    "table_name": "one_time_tokens",
    "index_name": "one_time_tokens_pkey",
    "index_definition": "CREATE UNIQUE INDEX one_time_tokens_pkey ON auth.one_time_tokens USING btree (id)"
  },
  {
    "schema_name": "auth",
    "table_name": "one_time_tokens",
    "index_name": "one_time_tokens_relates_to_hash_idx",
    "index_definition": "CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to)"
  },
  {
    "schema_name": "auth",
    "table_name": "one_time_tokens",
    "index_name": "one_time_tokens_token_hash_hash_idx",
    "index_definition": "CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash)"
  },
  {
    "schema_name": "auth",
    "table_name": "one_time_tokens",
    "index_name": "one_time_tokens_user_id_token_type_key",
    "index_definition": "CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type)"
  },
  {
    "schema_name": "auth",
    "table_name": "refresh_tokens",
    "index_name": "refresh_tokens_instance_id_idx",
    "index_definition": "CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id)"
  },
  {
    "schema_name": "auth",
    "table_name": "refresh_tokens",
    "index_name": "refresh_tokens_instance_id_user_id_idx",
    "index_definition": "CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id)"
  },
  {
    "schema_name": "auth",
    "table_name": "refresh_tokens",
    "index_name": "refresh_tokens_parent_idx",
    "index_definition": "CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent)"
  },
  {
    "schema_name": "auth",
    "table_name": "refresh_tokens",
    "index_name": "refresh_tokens_pkey",
    "index_definition": "CREATE UNIQUE INDEX refresh_tokens_pkey ON auth.refresh_tokens USING btree (id)"
  },
  {
    "schema_name": "auth",
    "table_name": "refresh_tokens",
    "index_name": "refresh_tokens_session_id_revoked_idx",
    "index_definition": "CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked)"
  },
  {
    "schema_name": "auth",
    "table_name": "refresh_tokens",
    "index_name": "refresh_tokens_token_unique",
    "index_definition": "CREATE UNIQUE INDEX refresh_tokens_token_unique ON auth.refresh_tokens USING btree (token)"
  },
  {
    "schema_name": "auth",
    "table_name": "refresh_tokens",
    "index_name": "refresh_tokens_updated_at_idx",
    "index_definition": "CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC)"
  },
  {
    "schema_name": "auth",
    "table_name": "saml_providers",
    "index_name": "saml_providers_entity_id_key",
    "index_definition": "CREATE UNIQUE INDEX saml_providers_entity_id_key ON auth.saml_providers USING btree (entity_id)"
  },
  {
    "schema_name": "auth",
    "table_name": "saml_providers",
    "index_name": "saml_providers_pkey",
    "index_definition": "CREATE UNIQUE INDEX saml_providers_pkey ON auth.saml_providers USING btree (id)"
  },
  {
    "schema_name": "auth",
    "table_name": "saml_providers",
    "index_name": "saml_providers_sso_provider_id_idx",
    "index_definition": "CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id)"
  },
  {
    "schema_name": "auth",
    "table_name": "saml_relay_states",
    "index_name": "saml_relay_states_created_at_idx",
    "index_definition": "CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC)"
  },
  {
    "schema_name": "auth",
    "table_name": "saml_relay_states",
    "index_name": "saml_relay_states_for_email_idx",
    "index_definition": "CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email)"
  },
  {
    "schema_name": "auth",
    "table_name": "saml_relay_states",
    "index_name": "saml_relay_states_pkey",
    "index_definition": "CREATE UNIQUE INDEX saml_relay_states_pkey ON auth.saml_relay_states USING btree (id)"
  },
  {
    "schema_name": "auth",
    "table_name": "saml_relay_states",
    "index_name": "saml_relay_states_sso_provider_id_idx",
    "index_definition": "CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id)"
  },
  {
    "schema_name": "auth",
    "table_name": "schema_migrations",
    "index_name": "schema_migrations_pkey",
    "index_definition": "CREATE UNIQUE INDEX schema_migrations_pkey ON auth.schema_migrations USING btree (version)"
  },
  {
    "schema_name": "auth",
    "table_name": "sessions",
    "index_name": "sessions_not_after_idx",
    "index_definition": "CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC)"
  },
  {
    "schema_name": "auth",
    "table_name": "sessions",
    "index_name": "sessions_pkey",
    "index_definition": "CREATE UNIQUE INDEX sessions_pkey ON auth.sessions USING btree (id)"
  },
  {
    "schema_name": "auth",
    "table_name": "sessions",
    "index_name": "sessions_user_id_idx",
    "index_definition": "CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id)"
  },
  {
    "schema_name": "auth",
    "table_name": "sessions",
    "index_name": "user_id_created_at_idx",
    "index_definition": "CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at)"
  },
  {
    "schema_name": "auth",
    "table_name": "sso_domains",
    "index_name": "sso_domains_domain_idx",
    "index_definition": "CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain))"
  },
  {
    "schema_name": "auth",
    "table_name": "sso_domains",
    "index_name": "sso_domains_pkey",
    "index_definition": "CREATE UNIQUE INDEX sso_domains_pkey ON auth.sso_domains USING btree (id)"
  },
  {
    "schema_name": "auth",
    "table_name": "sso_domains",
    "index_name": "sso_domains_sso_provider_id_idx",
    "index_definition": "CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id)"
  },
  {
    "schema_name": "auth",
    "table_name": "sso_providers",
    "index_name": "sso_providers_pkey",
    "index_definition": "CREATE UNIQUE INDEX sso_providers_pkey ON auth.sso_providers USING btree (id)"
  },
  {
    "schema_name": "auth",
    "table_name": "sso_providers",
    "index_name": "sso_providers_resource_id_idx",
    "index_definition": "CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id))"
  },
  {
    "schema_name": "auth",
    "table_name": "users",
    "index_name": "confirmation_token_idx",
    "index_definition": "CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text)"
  },
  {
    "schema_name": "auth",
    "table_name": "users",
    "index_name": "email_change_token_current_idx",
    "index_definition": "CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text)"
  },
  {
    "schema_name": "auth",
    "table_name": "users",
    "index_name": "email_change_token_new_idx",
    "index_definition": "CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text)"
  },
  {
    "schema_name": "auth",
    "table_name": "users",
    "index_name": "reauthentication_token_idx",
    "index_definition": "CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text)"
  },
  {
    "schema_name": "auth",
    "table_name": "users",
    "index_name": "recovery_token_idx",
    "index_definition": "CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text)"
  },
  {
    "schema_name": "auth",
    "table_name": "users",
    "index_name": "users_email_partial_key",
    "index_definition": "CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false)"
  },
  {
    "schema_name": "auth",
    "table_name": "users",
    "index_name": "users_instance_id_email_idx",
    "index_definition": "CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text))"
  },
  {
    "schema_name": "auth",
    "table_name": "users",
    "index_name": "users_instance_id_idx",
    "index_definition": "CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id)"
  },
  {
    "schema_name": "auth",
    "table_name": "users",
    "index_name": "users_is_anonymous_idx",
    "index_definition": "CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous)"
  },
  {
    "schema_name": "auth",
    "table_name": "users",
    "index_name": "users_phone_key",
    "index_definition": "CREATE UNIQUE INDEX users_phone_key ON auth.users USING btree (phone)"
  },
  {
    "schema_name": "auth",
    "table_name": "users",
    "index_name": "users_pkey",
    "index_definition": "CREATE UNIQUE INDEX users_pkey ON auth.users USING btree (id)"
  },
  {
    "schema_name": "cron",
    "table_name": "job",
    "index_name": "job_pkey",
    "index_definition": "CREATE UNIQUE INDEX job_pkey ON cron.job USING btree (jobid)"
  },
  {
    "schema_name": "cron",
    "table_name": "job",
    "index_name": "jobname_username_uniq",
    "index_definition": "CREATE UNIQUE INDEX jobname_username_uniq ON cron.job USING btree (jobname, username)"
  },
  {
    "schema_name": "cron",
    "table_name": "job_run_details",
    "index_name": "job_run_details_pkey",
    "index_definition": "CREATE UNIQUE INDEX job_run_details_pkey ON cron.job_run_details USING btree (runid)"
  },
  {
    "schema_name": "pgsodium",
    "table_name": "key",
    "index_name": "key_key_id_key_context_key_type_idx",
    "index_definition": "CREATE UNIQUE INDEX key_key_id_key_context_key_type_idx ON pgsodium.key USING btree (key_id, key_context, key_type)"
  },
  {
    "schema_name": "pgsodium",
    "table_name": "key",
    "index_name": "key_pkey",
    "index_definition": "CREATE UNIQUE INDEX key_pkey ON pgsodium.key USING btree (id)"
  },
  {
    "schema_name": "pgsodium",
    "table_name": "key",
    "index_name": "key_status_idx",
    "index_definition": "CREATE INDEX key_status_idx ON pgsodium.key USING btree (status) WHERE (status = ANY (ARRAY['valid'::pgsodium.key_status, 'default'::pgsodium.key_status]))"
  },
  {
    "schema_name": "pgsodium",
    "table_name": "key",
    "index_name": "key_status_idx1",
    "index_definition": "CREATE UNIQUE INDEX key_status_idx1 ON pgsodium.key USING btree (status) WHERE (status = 'default'::pgsodium.key_status)"
  },
  {
    "schema_name": "pgsodium",
    "table_name": "key",
    "index_name": "pgsodium_key_unique_name",
    "index_definition": "CREATE UNIQUE INDEX pgsodium_key_unique_name ON pgsodium.key USING btree (name)"
  },
  {
    "schema_name": "public",
    "table_name": "addresses",
    "index_name": "addresses_pkey",
    "index_definition": "CREATE UNIQUE INDEX addresses_pkey ON public.addresses USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "affiliate_levels",
    "index_name": "affiliate_levels_pkey",
    "index_definition": "CREATE UNIQUE INDEX affiliate_levels_pkey ON public.affiliate_levels USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "affiliate_profiles",
    "index_name": "affiliate_profiles_affiliate_code_key",
    "index_definition": "CREATE UNIQUE INDEX affiliate_profiles_affiliate_code_key ON public.affiliate_profiles USING btree (affiliate_code)"
  },
  {
    "schema_name": "public",
    "table_name": "affiliate_profiles",
    "index_name": "affiliate_profiles_pkey",
    "index_definition": "CREATE UNIQUE INDEX affiliate_profiles_pkey ON public.affiliate_profiles USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "affiliate_profiles",
    "index_name": "affiliate_profiles_user_id_key",
    "index_definition": "CREATE UNIQUE INDEX affiliate_profiles_user_id_key ON public.affiliate_profiles USING btree (user_id)"
  },
  {
    "schema_name": "public",
    "table_name": "affiliate_profiles",
    "index_name": "idx_affiliate_profiles_code",
    "index_definition": "CREATE INDEX idx_affiliate_profiles_code ON public.affiliate_profiles USING btree (affiliate_code)"
  },
  {
    "schema_name": "public",
    "table_name": "affiliate_profiles",
    "index_name": "idx_affiliate_profiles_monthly_earnings",
    "index_definition": "CREATE INDEX idx_affiliate_profiles_monthly_earnings ON public.affiliate_profiles USING btree (monthly_earnings)"
  },
  {
    "schema_name": "public",
    "table_name": "affiliate_profiles",
    "index_name": "idx_affiliate_profiles_total_earned",
    "index_definition": "CREATE INDEX idx_affiliate_profiles_total_earned ON public.affiliate_profiles USING btree (total_earned)"
  },
  {
    "schema_name": "public",
    "table_name": "article_archives",
    "index_name": "article_archives_pkey",
    "index_definition": "CREATE UNIQUE INDEX article_archives_pkey ON public.article_archives USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "article_categories",
    "index_name": "article_categories_pkey",
    "index_definition": "CREATE UNIQUE INDEX article_categories_pkey ON public.article_categories USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "article_service_compatibility",
    "index_name": "article_service_compatibility_article_id_service_id_key",
    "index_definition": "CREATE UNIQUE INDEX article_service_compatibility_article_id_service_id_key ON public.article_service_compatibility USING btree (article_id, service_id)"
  },
  {
    "schema_name": "public",
    "table_name": "article_service_compatibility",
    "index_name": "article_service_compatibility_pkey",
    "index_definition": "CREATE UNIQUE INDEX article_service_compatibility_pkey ON public.article_service_compatibility USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "article_service_prices",
    "index_name": "article_service_prices_article_id_service_type_id_key",
    "index_definition": "CREATE UNIQUE INDEX article_service_prices_article_id_service_type_id_key ON public.article_service_prices USING btree (article_id, service_type_id)"
  },
  {
    "schema_name": "public",
    "table_name": "article_service_prices",
    "index_name": "article_service_prices_pkey",
    "index_definition": "CREATE UNIQUE INDEX article_service_prices_pkey ON public.article_service_prices USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "article_service_prices",
    "index_name": "idx_article_service_prices_article_id",
    "index_definition": "CREATE INDEX idx_article_service_prices_article_id ON public.article_service_prices USING btree (article_id)"
  },
  {
    "schema_name": "public",
    "table_name": "article_service_prices",
    "index_name": "idx_article_service_prices_lookup",
    "index_definition": "CREATE INDEX idx_article_service_prices_lookup ON public.article_service_prices USING btree (article_id, service_type_id)"
  },
  {
    "schema_name": "public",
    "table_name": "article_service_prices",
    "index_name": "idx_article_service_prices_service_type_id",
    "index_definition": "CREATE INDEX idx_article_service_prices_service_type_id ON public.article_service_prices USING btree (service_type_id)"
  },
  {
    "schema_name": "public",
    "table_name": "article_services",
    "index_name": "article_services_article_id_service_id_key",
    "index_definition": "CREATE UNIQUE INDEX article_services_article_id_service_id_key ON public.article_services USING btree (article_id, service_id)"
  },
  {
    "schema_name": "public",
    "table_name": "article_services",
    "index_name": "article_services_pkey",
    "index_definition": "CREATE UNIQUE INDEX article_services_pkey ON public.article_services USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "articles",
    "index_name": "articles_pkey",
    "index_definition": "CREATE UNIQUE INDEX articles_pkey ON public.articles USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "blog_articles",
    "index_name": "blog_articles_pkey",
    "index_definition": "CREATE UNIQUE INDEX blog_articles_pkey ON public.blog_articles USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "blog_articles",
    "index_name": "idx_blog_articles_author",
    "index_definition": "CREATE INDEX idx_blog_articles_author ON public.blog_articles USING btree (author_id)"
  },
  {
    "schema_name": "public",
    "table_name": "blog_articles",
    "index_name": "idx_blog_articles_category",
    "index_definition": "CREATE INDEX idx_blog_articles_category ON public.blog_articles USING btree (category_id)"
  },
  {
    "schema_name": "public",
    "table_name": "blog_articles",
    "index_name": "idx_blog_articles_published",
    "index_definition": "CREATE INDEX idx_blog_articles_published ON public.blog_articles USING btree (published_at)"
  },
  {
    "schema_name": "public",
    "table_name": "blog_categories",
    "index_name": "blog_categories_name_key",
    "index_definition": "CREATE UNIQUE INDEX blog_categories_name_key ON public.blog_categories USING btree (name)"
  },
  {
    "schema_name": "public",
    "table_name": "blog_categories",
    "index_name": "blog_categories_pkey",
    "index_definition": "CREATE UNIQUE INDEX blog_categories_pkey ON public.blog_categories USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "commissionTransactions",
    "index_name": "commission_transactions_pkey",
    "index_definition": "CREATE UNIQUE INDEX commission_transactions_pkey ON public.\"commissionTransactions\" USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "commissionTransactions",
    "index_name": "idx_commission_transactions_status",
    "index_definition": "CREATE INDEX idx_commission_transactions_status ON public.\"commissionTransactions\" USING btree (status)"
  },
  {
    "schema_name": "public",
    "table_name": "discount_rules",
    "index_name": "discount_rules_pkey",
    "index_definition": "CREATE UNIQUE INDEX discount_rules_pkey ON public.discount_rules USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "loyalty_points",
    "index_name": "loyalty_points_pkey",
    "index_definition": "CREATE UNIQUE INDEX loyalty_points_pkey ON public.loyalty_points USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "loyalty_points",
    "index_name": "loyalty_points_user_id_key",
    "index_definition": "CREATE UNIQUE INDEX loyalty_points_user_id_key ON public.loyalty_points USING btree (user_id)"
  },
  {
    "schema_name": "public",
    "table_name": "notification_preferences",
    "index_name": "idx_notification_preferences_user_id",
    "index_definition": "CREATE INDEX idx_notification_preferences_user_id ON public.notification_preferences USING btree (user_id)"
  },
  {
    "schema_name": "public",
    "table_name": "notification_preferences",
    "index_name": "notification_preferences_pkey",
    "index_definition": "CREATE UNIQUE INDEX notification_preferences_pkey ON public.notification_preferences USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "notification_preferences",
    "index_name": "notification_preferences_user_id_key",
    "index_definition": "CREATE UNIQUE INDEX notification_preferences_user_id_key ON public.notification_preferences USING btree (user_id)"
  },
  {
    "schema_name": "public",
    "table_name": "notification_rules",
    "index_name": "notification_rules_event_type_user_role_key",
    "index_definition": "CREATE UNIQUE INDEX notification_rules_event_type_user_role_key ON public.notification_rules USING btree (event_type, user_role)"
  },
  {
    "schema_name": "public",
    "table_name": "notification_rules",
    "index_name": "notification_rules_pkey",
    "index_definition": "CREATE UNIQUE INDEX notification_rules_pkey ON public.notification_rules USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "notifications",
    "index_name": "idx_notifications_created",
    "index_definition": "CREATE INDEX idx_notifications_created ON public.notifications USING btree (created_at DESC)"
  },
  {
    "schema_name": "public",
    "table_name": "notifications",
    "index_name": "idx_notifications_type",
    "index_definition": "CREATE INDEX idx_notifications_type ON public.notifications USING btree (type)"
  },
  {
    "schema_name": "public",
    "table_name": "notifications",
    "index_name": "idx_notifications_user_id",
    "index_definition": "CREATE INDEX idx_notifications_user_id ON public.notifications USING btree (user_id)"
  },
  {
    "schema_name": "public",
    "table_name": "notifications",
    "index_name": "notifications_pkey",
    "index_definition": "CREATE UNIQUE INDEX notifications_pkey ON public.notifications USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "offer_articles",
    "index_name": "offer_articles_pkey",
    "index_definition": "CREATE UNIQUE INDEX offer_articles_pkey ON public.offer_articles USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "offers",
    "index_name": "offers_pkey",
    "index_definition": "CREATE UNIQUE INDEX offers_pkey ON public.offers USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "order_items",
    "index_name": "idx_order_items_article_id",
    "index_definition": "CREATE INDEX idx_order_items_article_id ON public.order_items USING btree (\"articleId\")"
  },
  {
    "schema_name": "public",
    "table_name": "order_items",
    "index_name": "idx_order_items_order_id",
    "index_definition": "CREATE INDEX idx_order_items_order_id ON public.order_items USING btree (\"orderId\")"
  },
  {
    "schema_name": "public",
    "table_name": "order_items",
    "index_name": "order_items_article_premium_unique",
    "index_definition": "CREATE UNIQUE INDEX order_items_article_premium_unique ON public.order_items USING btree (\"orderId\", \"articleId\", \"isPremium\")"
  },
  {
    "schema_name": "public",
    "table_name": "order_items",
    "index_name": "order_items_pkey",
    "index_definition": "CREATE UNIQUE INDEX order_items_pkey ON public.order_items USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "order_metadata",
    "index_name": "idx_order_metadata_flash",
    "index_definition": "CREATE INDEX idx_order_metadata_flash ON public.order_metadata USING btree (is_flash_order)"
  },
  {
    "schema_name": "public",
    "table_name": "order_metadata",
    "index_name": "order_metadata_pkey",
    "index_definition": "CREATE UNIQUE INDEX order_metadata_pkey ON public.order_metadata USING btree (order_id)"
  },
  {
    "schema_name": "public",
    "table_name": "order_notes",
    "index_name": "idx_order_notes_order_id",
    "index_definition": "CREATE INDEX idx_order_notes_order_id ON public.order_notes USING btree (order_id)"
  },
  {
    "schema_name": "public",
    "table_name": "order_notes",
    "index_name": "order_notes_pkey",
    "index_definition": "CREATE UNIQUE INDEX order_notes_pkey ON public.order_notes USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "order_weights",
    "index_name": "order_weights_pkey",
    "index_definition": "CREATE UNIQUE INDEX order_weights_pkey ON public.order_weights USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "orders",
    "index_name": "idx_orders_address_id",
    "index_definition": "CREATE INDEX idx_orders_address_id ON public.orders USING btree (\"addressId\")"
  },
  {
    "schema_name": "public",
    "table_name": "orders",
    "index_name": "idx_orders_payment_method",
    "index_definition": "CREATE INDEX idx_orders_payment_method ON public.orders USING btree (\"paymentMethod\")"
  },
  {
    "schema_name": "public",
    "table_name": "orders",
    "index_name": "idx_orders_service_id",
    "index_definition": "CREATE INDEX idx_orders_service_id ON public.orders USING btree (\"serviceId\")"
  },
  {
    "schema_name": "public",
    "table_name": "orders",
    "index_name": "idx_orders_service_type_id",
    "index_definition": "CREATE INDEX idx_orders_service_type_id ON public.orders USING btree (service_type_id)"
  },
  {
    "schema_name": "public",
    "table_name": "orders",
    "index_name": "idx_orders_status",
    "index_definition": "CREATE INDEX idx_orders_status ON public.orders USING btree (status)"
  },
  {
    "schema_name": "public",
    "table_name": "orders",
    "index_name": "idx_orders_user_id",
    "index_definition": "CREATE INDEX idx_orders_user_id ON public.orders USING btree (\"userId\")"
  },
  {
    "schema_name": "public",
    "table_name": "orders",
    "index_name": "orders_pkey",
    "index_definition": "CREATE UNIQUE INDEX orders_pkey ON public.orders USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "orders_archive",
    "index_name": "idx_orders_archive_archived",
    "index_definition": "CREATE INDEX idx_orders_archive_archived ON public.orders_archive USING btree (archived_at)"
  },
  {
    "schema_name": "public",
    "table_name": "orders_archive",
    "index_name": "idx_orders_archive_createdat",
    "index_definition": "CREATE INDEX idx_orders_archive_createdat ON public.orders_archive USING btree (\"createdAt\")"
  },
  {
    "schema_name": "public",
    "table_name": "orders_archive",
    "index_name": "idx_orders_archive_status",
    "index_definition": "CREATE INDEX idx_orders_archive_status ON public.orders_archive USING btree (status)"
  },
  {
    "schema_name": "public",
    "table_name": "orders_archive",
    "index_name": "idx_orders_archive_userid",
    "index_definition": "CREATE INDEX idx_orders_archive_userid ON public.orders_archive USING btree (\"userId\")"
  },
  {
    "schema_name": "public",
    "table_name": "orders_archive",
    "index_name": "orders_archive_pkey",
    "index_definition": "CREATE UNIQUE INDEX orders_archive_pkey ON public.orders_archive USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "point_transactions",
    "index_name": "idx_point_transactions_user_id",
    "index_definition": "CREATE INDEX idx_point_transactions_user_id ON public.point_transactions USING btree (\"userId\")"
  },
  {
    "schema_name": "public",
    "table_name": "point_transactions",
    "index_name": "point_transactions_pkey",
    "index_definition": "CREATE UNIQUE INDEX point_transactions_pkey ON public.point_transactions USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "price_configurations",
    "index_name": "price_configurations_pkey",
    "index_definition": "CREATE UNIQUE INDEX price_configurations_pkey ON public.price_configurations USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "price_history",
    "index_name": "price_history_pkey",
    "index_definition": "CREATE UNIQUE INDEX price_history_pkey ON public.price_history USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "reset_codes",
    "index_name": "idx_reset_codes_code",
    "index_definition": "CREATE INDEX idx_reset_codes_code ON public.reset_codes USING btree (code)"
  },
  {
    "schema_name": "public",
    "table_name": "reset_codes",
    "index_name": "idx_reset_codes_email",
    "index_definition": "CREATE INDEX idx_reset_codes_email ON public.reset_codes USING btree (email)"
  },
  {
    "schema_name": "public",
    "table_name": "reset_codes",
    "index_name": "idx_reset_codes_user_id",
    "index_definition": "CREATE INDEX idx_reset_codes_user_id ON public.reset_codes USING btree (user_id)"
  },
  {
    "schema_name": "public",
    "table_name": "reset_codes",
    "index_name": "reset_codes_pkey",
    "index_definition": "CREATE UNIQUE INDEX reset_codes_pkey ON public.reset_codes USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "reward_claims",
    "index_name": "reward_claims_pkey",
    "index_definition": "CREATE UNIQUE INDEX reward_claims_pkey ON public.reward_claims USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "rewards",
    "index_name": "rewards_pkey",
    "index_definition": "CREATE UNIQUE INDEX rewards_pkey ON public.rewards USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "service_specific_prices",
    "index_name": "service_specific_prices_article_id_service_id_key",
    "index_definition": "CREATE UNIQUE INDEX service_specific_prices_article_id_service_id_key ON public.service_specific_prices USING btree (article_id, service_id)"
  },
  {
    "schema_name": "public",
    "table_name": "service_specific_prices",
    "index_name": "service_specific_prices_pkey",
    "index_definition": "CREATE UNIQUE INDEX service_specific_prices_pkey ON public.service_specific_prices USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "service_types",
    "index_name": "idx_service_types_default",
    "index_definition": "CREATE INDEX idx_service_types_default ON public.service_types USING btree (is_default)"
  },
  {
    "schema_name": "public",
    "table_name": "service_types",
    "index_name": "idx_service_types_weight",
    "index_definition": "CREATE INDEX idx_service_types_weight ON public.service_types USING btree (requires_weight)"
  },
  {
    "schema_name": "public",
    "table_name": "service_types",
    "index_name": "service_types_name_key",
    "index_definition": "CREATE UNIQUE INDEX service_types_name_key ON public.service_types USING btree (name)"
  },
  {
    "schema_name": "public",
    "table_name": "service_types",
    "index_name": "service_types_pkey",
    "index_definition": "CREATE UNIQUE INDEX service_types_pkey ON public.service_types USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "services",
    "index_name": "services_pkey",
    "index_definition": "CREATE UNIQUE INDEX services_pkey ON public.services USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "subscription_plans",
    "index_name": "subscription_plans_pkey",
    "index_definition": "CREATE UNIQUE INDEX subscription_plans_pkey ON public.subscription_plans USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "user_offers",
    "index_name": "user_offers_pkey",
    "index_definition": "CREATE UNIQUE INDEX user_offers_pkey ON public.user_offers USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "user_subscriptions",
    "index_name": "user_subscriptions_pkey",
    "index_definition": "CREATE UNIQUE INDEX user_subscriptions_pkey ON public.user_subscriptions USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "users",
    "index_name": "idx_users_email",
    "index_definition": "CREATE INDEX idx_users_email ON public.users USING btree (email)"
  },
  {
    "schema_name": "public",
    "table_name": "users",
    "index_name": "idx_users_referral_code",
    "index_definition": "CREATE INDEX idx_users_referral_code ON public.users USING btree (referral_code)"
  },
  {
    "schema_name": "public",
    "table_name": "users",
    "index_name": "users_email_key",
    "index_definition": "CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email)"
  },
  {
    "schema_name": "public",
    "table_name": "users",
    "index_name": "users_pkey",
    "index_definition": "CREATE UNIQUE INDEX users_pkey ON public.users USING btree (id)"
  },
  {
    "schema_name": "public",
    "table_name": "weight_based_pricing",
    "index_name": "weight_based_pricing_pkey",
    "index_definition": "CREATE UNIQUE INDEX weight_based_pricing_pkey ON public.weight_based_pricing USING btree (id)"
  },
  {
    "schema_name": "realtime",
    "table_name": "messages",
    "index_name": "messages_pkey",
    "index_definition": "CREATE UNIQUE INDEX messages_pkey ON ONLY realtime.messages USING btree (id, inserted_at)"
  },
  {
    "schema_name": "realtime",
    "table_name": "schema_migrations",
    "index_name": "schema_migrations_pkey",
    "index_definition": "CREATE UNIQUE INDEX schema_migrations_pkey ON realtime.schema_migrations USING btree (version)"
  },
  {
    "schema_name": "realtime",
    "table_name": "subscription",
    "index_name": "ix_realtime_subscription_entity",
    "index_definition": "CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity)"
  },
  {
    "schema_name": "realtime",
    "table_name": "subscription",
    "index_name": "pk_subscription",
    "index_definition": "CREATE UNIQUE INDEX pk_subscription ON realtime.subscription USING btree (id)"
  },
  {
    "schema_name": "realtime",
    "table_name": "subscription",
    "index_name": "subscription_subscription_id_entity_filters_key",
    "index_definition": "CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters)"
  },
  {
    "schema_name": "storage",
    "table_name": "buckets",
    "index_name": "bname",
    "index_definition": "CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name)"
  },
  {
    "schema_name": "storage",
    "table_name": "buckets",
    "index_name": "buckets_pkey",
    "index_definition": "CREATE UNIQUE INDEX buckets_pkey ON storage.buckets USING btree (id)"
  },
  {
    "schema_name": "storage",
    "table_name": "migrations",
    "index_name": "migrations_name_key",
    "index_definition": "CREATE UNIQUE INDEX migrations_name_key ON storage.migrations USING btree (name)"
  },
  {
    "schema_name": "storage",
    "table_name": "migrations",
    "index_name": "migrations_pkey",
    "index_definition": "CREATE UNIQUE INDEX migrations_pkey ON storage.migrations USING btree (id)"
  },
  {
    "schema_name": "storage",
    "table_name": "objects",
    "index_name": "bucketid_objname",
    "index_definition": "CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name)"
  },
  {
    "schema_name": "storage",
    "table_name": "objects",
    "index_name": "idx_objects_bucket_id_name",
    "index_definition": "CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE \"C\")"
  },
  {
    "schema_name": "storage",
    "table_name": "objects",
    "index_name": "name_prefix_search",
    "index_definition": "CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops)"
  },
  {
    "schema_name": "storage",
    "table_name": "objects",
    "index_name": "objects_pkey",
    "index_definition": "CREATE UNIQUE INDEX objects_pkey ON storage.objects USING btree (id)"
  },
  {
    "schema_name": "storage",
    "table_name": "s3_multipart_uploads",
    "index_name": "idx_multipart_uploads_list",
    "index_definition": "CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at)"
  },
  {
    "schema_name": "storage",
    "table_name": "s3_multipart_uploads",
    "index_name": "s3_multipart_uploads_pkey",
    "index_definition": "CREATE UNIQUE INDEX s3_multipart_uploads_pkey ON storage.s3_multipart_uploads USING btree (id)"
  },
  {
    "schema_name": "storage",
    "table_name": "s3_multipart_uploads_parts",
    "index_name": "s3_multipart_uploads_parts_pkey",
    "index_definition": "CREATE UNIQUE INDEX s3_multipart_uploads_parts_pkey ON storage.s3_multipart_uploads_parts USING btree (id)"
  },
  {
    "schema_name": "vault",
    "table_name": "secrets",
    "index_name": "secrets_name_idx",
    "index_definition": "CREATE UNIQUE INDEX secrets_name_idx ON vault.secrets USING btree (name) WHERE (name IS NOT NULL)"
  },
  {
    "schema_name": "vault",
    "table_name": "secrets",
    "index_name": "secrets_pkey",
    "index_definition": "CREATE UNIQUE INDEX secrets_pkey ON vault.secrets USING btree (id)"
  }
]