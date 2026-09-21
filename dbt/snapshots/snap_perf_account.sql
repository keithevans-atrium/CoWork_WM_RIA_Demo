select
    record_pk,
    account_number,
    account_name,
    portfolio_id,
    registration_type,
    status,
    model_id,
    advisor_code,
    custodian_code,
    fee_schedule,
    is_discretionary,
    total_market_value,
    as_of_date,
    change_key
from {{ ref('brz_perf_account') }}
