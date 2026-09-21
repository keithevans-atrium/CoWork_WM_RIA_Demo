select
    record_pk,
    position_id,
    account_number,
    as_of_date,
    cusip,
    ticker,
    security_description,
    security_type,
    quantity,
    price,
    market_value,
    cost_basis,
    cost_basis_method,
    accrued_income,
    change_key
from {{ ref('raw_position') }}
