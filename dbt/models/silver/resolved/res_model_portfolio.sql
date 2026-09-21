with perf as (
    select * from {{ source('performance_system', 'model_portfolio') }}
)

select
    perf.model_id,

    perf.model_name                         as perf_model_name,
    coalesce(perf.model_name)               as resolved_model_name,

    perf.model_description,
    perf.risk_profile,
    perf.equity_target_pct,
    perf.fixed_income_target_pct,
    perf.alternative_target_pct,
    perf.cash_target_pct,
    perf.benchmark_id,
    perf.is_active,
    perf.last_rebalance_date,

    'PERF_ONLY' as match_status,
    current_timestamp() as resolved_at

from perf
