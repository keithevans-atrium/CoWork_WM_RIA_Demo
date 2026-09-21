select
    {{ generate_pk(['record_pk', 'dbt_valid_from']) }} as account_history_id,
    account_number as account_id,
    total_market_value as market_value,
    null as cash_balance,
    status,
    fee_schedule,
    null as management_fee_rate,
    model_id,
    version_number,
    dbt_valid_from as valid_from,
    dbt_valid_to as valid_to,
    is_current,
    coalesce(dbt_is_deleted, false) as is_deleted,
    current_timestamp() as resolved_at

from {{ ref('stg_perf_account') }}
