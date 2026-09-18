# CoWork_WM_RIA_Demo

RIA Wealth Management platform on Snowflake — data pipeline, AI agents, and analytics apps.

## Architecture

```
KEVANS_WH_RIA (Source)              KEVANS_WH_RIA_AI_READY (Target)
├── SALESFORCE_FSC          ──►     ├── BRONZE (1:1 source views)
├── PERFORMANCE_SYSTEM      ──►     ├── SILVER (enriched + canonical)
└── CUSTODIAN               ──►     ├── GOLD (dims, facts, KPIs)
                                    ├── GOLD_AGENT (semantic views)
                                    └── SNAPSHOTS (SCD Type 2)
```

## Components

| Component | Path | Purpose |
|-----------|------|---------|
| **DCM** | `dcm/` | Infrastructure-as-code: schemas, roles, grants |
| **dbt** | `dbt/` | Bronze → Silver → Gold transformation pipeline |
| **Streamlit** | `streamlit/` | Advisor dashboard, client portal, portfolio analytics |
| **Agents** | `agents/` | Cortex Agents + semantic views for NL querying |

## Deployment

All components deploy via `snow` CLI:

```bash
snow dcm deploy          # infrastructure
dbt build                # transformations
snow streamlit deploy    # apps
```

## Snowflake Account

- **Account**: LTA38753
- **Source DB**: KEVANS_WH_RIA
- **Target DB**: KEVANS_WH_RIA_AI_READY
