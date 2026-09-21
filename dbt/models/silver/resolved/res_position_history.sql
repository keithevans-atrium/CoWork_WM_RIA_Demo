select
    {{ generate_pk(['record_pk', 'dbt_valid_from']) }} as position_history_id,
    account_number as account_id,
    cusip as security_id,
    as_of_date,
    quantity,
    market_value,
    cost_basis,
    unrealized_gain_loss,
    version_number,
    dbt_valid_from as valid_from,
    dbt_valid_to as valid_to,
    is_current,
    current_timestamp() as resolved_at

from {{ ref('stg_perf_portfolio_holdings') }}
