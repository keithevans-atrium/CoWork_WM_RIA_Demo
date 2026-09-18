select
    benchmark_id,
    benchmark_name,
    benchmark_ticker,
    benchmark_type,
    asset_class,
    is_active
from {{ source('performance_system', 'benchmark') }}
