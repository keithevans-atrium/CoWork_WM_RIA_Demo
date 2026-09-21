with perf_acct as (
    select account_number, model_id
    from {{ ref('stg_perf_account') }}
    where is_current = true and model_id is not null
)

select
    {{ generate_pk(['account_number', 'model_id']) }} as account_model_id,
    account_number as account_id,
    model_id,
    current_date() as effective_from,
    null as effective_to,
    true as is_current,
    current_timestamp() as resolved_at

from perf_acct
