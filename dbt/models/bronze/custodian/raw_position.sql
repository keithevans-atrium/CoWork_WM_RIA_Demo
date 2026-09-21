select
    {{ generate_pk(['position_id']) }} as record_pk,
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
    loaded_at,
    'custodian' as _source_system,
    current_timestamp() as _loaded_at,
    'POSITION' as _record_source,
    {{ generate_change_key([
        'account_number', 'as_of_date', 'cusip', 'ticker', 'security_description',
        'security_type', 'quantity', 'price', 'market_value', 'cost_basis',
        'cost_basis_method', 'accrued_income'
    ]) }} as change_key
from {{ source('custodian', 'position') }}
