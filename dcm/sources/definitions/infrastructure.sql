-- Infrastructure definitions for KEVANS_WH_RIA_AI_READY
-- Schemas aligned to Bronze / Silver / Gold medallion architecture

-- Bronze: raw source views (1:1 from source systems)
DEFINE SCHEMA KEVANS_WH_RIA_AI_READY.BRONZE
    COMMENT = 'Raw source data - 1:1 views from KEVANS_WH_RIA source systems';

-- Silver: enriched and canonical business entities
DEFINE SCHEMA KEVANS_WH_RIA_AI_READY.SILVER
    COMMENT = 'Enriched and resolved canonical entities (Security, Client, Account Value, Positions)';

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
