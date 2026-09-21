# CoWork_WM_RIA_Demo

RIA Wealth Management platform on Snowflake — data pipeline, AI agents, and analytics apps.

## Architecture

```
KEVANS_WH_RIA (Source)                    KEVANS_WH_RIA_AI_READY (Target)
├── SALESFORCE_FSC (6 tables)    ──►      ├── BRONZE      (14 raw_ views)
├── PERFORMANCE_SYSTEM (7 tables)──►      ├── SNAPSHOTS   (14 SCD2 tables)
└── CUSTODIAN (6 tables)         ──►      ├── SILVER      (staged → resolved → canonical)
                                          ├── GOLD        (dims + facts + aggregates)
                                          ├── GOLD_AGENT  (semantic views + Cortex Agents)
                                          └── GOLD_VISUAL (KPI tables for dashboards)
```

### Data Flow (DAG)

```
raw_ ──► snap_ ──► stg_ ──► res_ ──► slv_ ──► dim_ / fct_ / agg_
(bronze)  (snapshot) (staged)  (resolved) (canonical) (gold)
   │                    │          │           │            │
   │                    │          │           │            └─ Consumption: dims, facts, KPIs
   │                    │          │           └─ Canonical business entities
   │                    │          └─ Attribution resolution (golden record)
   │                    └─ Version number + is_current flag
   │                    └─ SCD2 with hard_deletes: new_record
   └─ 1:1 source views + record_pk + change_key + metadata
```

### Fort Knox Boundary

The AI layer (Cortex Agents, Semantic Views) only sees Gold — never Bronze or Silver. This ensures all agent responses are grounded in governed, resolved data.

## Project Structure

```
CoWork_WM_RIA_Demo/
├── snowflake.yml                          # snow CLI project config
├── .github/workflows/                     # CI/CD (GitHub Actions)
│
├── dcm/                                   # Database Change Management
│   ├── manifest.yml
│   └── sources/definitions/
│       └── infrastructure.sql             # Schema definitions (BRONZE, SILVER, GOLD, etc.)
│
├── dbt/                                   # Transformation Pipeline
│   ├── dbt_project.yml
│   ├── macros/
│   │   ├── generate_keys.sql              # generate_pk(), generate_change_key()
│   │   └── stage_snapshot.sql             # stage_snapshot() — adds versioning
│   │
│   ├── models/
│   │   ├── bronze/                        # Layer 1: Raw source views
│   │   │   ├── salesforce_fsc/            #   raw_account, raw_contact, raw_advisor, ...
│   │   │   ├── performance_system/        #   raw_perf_account, raw_portfolio_return, ...
│   │   │   └── custodian/                 #   raw_custodial_account, raw_position, ...
│   │   │
│   │   ├── silver/
│   │   │   ├── staged/                    # Layer 2a: Versioned snapshots
│   │   │   │                              #   stg_fsc_account, stg_cust_position, ...
│   │   │   ├── resolved/                  # Layer 2b: Attribution resolution
│   │   │   │                              #   res_client (source values + golden record)
│   │   │   └── canonical/                 # Layer 2c: Normalized business entities
│   │   │                                  #   slv_client, slv_account_value, slv_position, ...
│   │   │
│   │   └── gold/                          # Layer 3: Consumption
│   │       ├── dims/                      #   dim_client, dim_advisor, dim_account, dim_security
│   │       ├── facts/                     #   fct_portfolio_return, fct_transaction, fct_fee_billing
│   │       └── aggregates/                #   agg_aum_summary
│   │
│   └── snapshots/                         # SCD Type 2 (dbt 1.9+ YAML format)
│       ├── snap_fsc_*.sql / .yml          #   FSC entity snapshots
│       ├── snap_perf_*.sql / .yml         #   Performance entity snapshots
│       └── snap_cust_*.sql / .yml         #   Custodian entity snapshots
│
├── streamlit/                             # Streamlit-in-Snowflake Apps
│   ├── advisor_dashboard/
│   ├── client_portal/
│   └── portfolio_analytics/
│
└── agents/                                # Cortex Agents + Semantic Views
    ├── semantic_views/
    └── agent_definitions/
```

## Model Inventory

| Layer | Count | Prefix | Description |
|-------|-------|--------|-------------|
| Bronze | 14 | `raw_` | 1:1 source views with `record_pk`, `change_key`, `_source_system`, `_loaded_at`, `_record_source` |
| Snapshots | 14 | `snap_{src}_` | SCD Type 2 with `hard_deletes: new_record`, check strategy on `change_key` |
| Staged | 14 | `stg_{src}_` | Adds `version_number`, `reverse_version_number`, `is_current` |
| Resolved | 1 | `res_` | Attribution resolution — exposes each source's value + resolved golden record |
| Canonical | 5 | `slv_` | Normalized business entities (Client, Account Value, Position, Advisor Book, Fee Detail) |
| Gold Dims | 4 | `dim_` | `dim_client`, `dim_advisor`, `dim_account`, `dim_security` |
| Gold Facts | 3 | `fct_` | `fct_portfolio_return`, `fct_transaction`, `fct_fee_billing` |
| Gold Agg | 1 | `agg_` | `agg_aum_summary` |
| **Total** | **56** | | |

## Key Patterns

### Surrogate Keys & Change Detection

Every bronze model includes:
- `record_pk` — MD5 hash of the natural key (surrogate key)
- `change_key` — MD5 hash of all business columns (change detection for SCD2)

Generated via `generate_pk()` and `generate_change_key()` macros.

### Snapshot Versioning

The `stage_snapshot()` macro adds:
- `version_number` — ascending (1 = original record)
- `reverse_version_number` — descending (1 = latest version)
- `is_current` — `true` when `dbt_valid_to` is null and not deleted

### Attribution Resolution

The `res_` layer exposes every source system's value for shared attributes (e.g., `fsc_first_name`, `cust_first_name`) alongside a `resolved_*` golden value using priority-based coalesce. Includes `match_status` for cross-system linkage quality.

## Source Systems

| Source | Schema | Tables | Description |
|--------|--------|--------|-------------|
| Salesforce FSC | `SALESFORCE_FSC` | 9 | CRM — accounts, contacts, advisors, teams, opportunities, goals |
| Performance System | `PERFORMANCE_SYSTEM` | 7 | Returns, holdings, benchmarks, model portfolios |
| Custodian | `CUSTODIAN` | 6 | Positions, transactions, cash, fees, tax lots |

## Deployment

```bash
# Infrastructure
snow dcm deploy

# Transformations
cd dbt && dbt build

# Snapshots
cd dbt && dbt snapshot

# Apps
snow streamlit deploy --entity advisor_dashboard

# All via CI/CD
git push origin main  # triggers GitHub Actions
```

## Snowflake

- **Account**: LTA38753
- **Source DB**: `KEVANS_WH_RIA`
- **Target DB**: `KEVANS_WH_RIA_AI_READY`
- **Connection**: `atrium` (JWT auth)
- **CLI**: `snow` v3.15+ / `dbt-snowflake` v1.10.2
