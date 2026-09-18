select
    account_number,
    account_name,
    portfolio_id,
    registration_type,
    inception_date,
    close_date,
    status,
    model_id,
    advisor_code,
    custodian_code,
    fee_schedule,
    is_discretionary,
    total_market_value,
    as_of_date,
    loaded_at
from {{ source('performance_system', 'account') }}
