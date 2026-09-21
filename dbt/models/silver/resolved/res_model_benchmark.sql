with models as (
    select model_id, benchmark_id
    from {{ source('performance_system', 'model_portfolio') }}
    where is_active = true and benchmark_id is not null
)

select
    {{ generate_pk(['model_id', 'benchmark_id']) }} as model_benchmark_id,
    model_id,
    benchmark_id,
    current_date() as effective_from,
    null as effective_to,
    true as is_current,
    current_timestamp() as resolved_at

from models
