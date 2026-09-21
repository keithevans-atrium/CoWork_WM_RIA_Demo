with perf as (
    select * from {{ ref('stg_perf_benchmark') }} where is_current = true
)

select
    perf.benchmark_id,

    perf.benchmark_name                     as perf_benchmark_name,
    coalesce(perf.benchmark_name)           as resolved_benchmark_name,

    perf.benchmark_ticker                   as perf_benchmark_ticker,
    coalesce(perf.benchmark_ticker)         as resolved_benchmark_ticker,

    perf.benchmark_type                     as perf_benchmark_type,
    coalesce(perf.benchmark_type)           as resolved_benchmark_type,

    perf.asset_class,
    perf.is_active,

    'PERF_ONLY' as match_status,
    current_timestamp() as resolved_at

from perf
