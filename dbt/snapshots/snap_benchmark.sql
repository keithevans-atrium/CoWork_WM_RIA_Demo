select
    record_pk,
    benchmark_id,
    benchmark_name,
    benchmark_ticker,
    benchmark_type,
    asset_class,
    is_active,
    change_key
from {{ ref('brz_benchmark') }}
