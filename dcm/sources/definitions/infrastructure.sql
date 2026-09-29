-- Infrastructure definitions for KEVANS_WH_RIA_AI_READY
-- Schemas aligned to Bronze / Silver / Gold medallion architecture

-- Bronze: raw source views (1:1 from source systems)
DEFINE SCHEMA KEVANS_WH_RIA_AI_READY.BRONZE
    COMMENT = 'Raw source data - 1:1 views from KEVANS_WH_RIA source systems';

-- Silver Staged: versioned snapshot data with SCD2 tracking columns
DEFINE SCHEMA KEVANS_WH_RIA_AI_READY.SILVER_STAGED
    COMMENT = 'Staged snapshot data with version_number, reverse_version_number, is_current';

-- Silver Resolved: attribution-resolved entities with cross-system reconciliation
DEFINE SCHEMA KEVANS_WH_RIA_AI_READY.SILVER_RESOLVED
    COMMENT = 'Attribution-resolved entities exposing source-level values alongside golden resolved values';

-- Silver Canonical: normalized business entities ready for gold consumption
DEFINE SCHEMA KEVANS_WH_RIA_AI_READY.SILVER_CANONICAL
    COMMENT = 'Canonical normalized business entities derived from resolved layer';

-- Gold Cortex Ready: dims and facts with metadata for AI consumption
DEFINE SCHEMA KEVANS_WH_RIA_AI_READY.GOLD
    WITH MANAGED ACCESS
    COMMENT = 'Cortex-ready dimensions and facts with data + metadata';

-- Gold Cortex Agent: semantic views, gloss tables, agent definitions
DEFINE SCHEMA KEVANS_WH_RIA_AI_READY.GOLD_AGENT
    WITH MANAGED ACCESS
    COMMENT = 'Cortex Agent layer - semantic views, gloss, orchestration (Fort Knox boundary)';

-- Gold Visual: KPI tables for dashboards and Streamlit apps
DEFINE SCHEMA KEVANS_WH_RIA_AI_READY.GOLD_VISUAL
    WITH MANAGED ACCESS
    COMMENT = 'Visual layer - global KPI tables for dashboards and reporting';

-- Snapshots: SCD Type 2 historical tracking
DEFINE SCHEMA KEVANS_WH_RIA_AI_READY.SNAPSHOTS
    COMMENT = 'dbt snapshots - SCD Type 2 history for client segments, balances, allocations'
    DATA_RETENTION_TIME_IN_DAYS = 90;

-- ============================================================
-- Tags
-- ============================================================

-- Domain tag: classifies tables/views by business domain
DEFINE TAG KEVANS_WH_RIA_AI_READY.GOLD.DOMAIN
    ALLOWED_VALUES
        'Client',
        'Account',
        'Advisor',
        'Team',
        'Security',
        'Transaction',
        'Fee',
        'Return',
        'Opportunity',
        'Goal',
        'Position',
        'Benchmark',
        'Model Portfolio'
    COMMENT = 'Business domain classification for tables and views';

-- PII tag: classifies columns containing personally identifiable information
DEFINE TAG KEVANS_WH_RIA_AI_READY.GOLD.PII
    ALLOWED_VALUES
        'Name',
        'Email',
        'Phone',
        'Address',
        'SSN',
        'Date of Birth',
        'Tax ID'
    COMMENT = 'Personally Identifiable Information classification for columns';
