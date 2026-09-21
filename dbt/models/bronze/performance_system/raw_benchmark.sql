select
    {{ generate_pk(['benchmark_id']) }} as record_pk,
    benchmark_id,
    benchmark_name,
    benchmark_ticker,
    benchmark_type,
    asset_class,
    is_active,
    'performance_system' as _source_system,
    current_timestamp() as _loaded_at,
    'BENCHMARK' as _record_source,
    {{ generate_change_key([
        'benchmark_name', 'benchmark_ticker', 'benchmark_type', 'asset_class', 'is_active'
    ]) }} as change_key
from {{ source('performance_system', 'benchmark') }}
