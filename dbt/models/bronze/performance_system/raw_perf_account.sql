select
    {{ generate_pk(['account_number']) }} as record_pk,
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
    loaded_at,
    'performance_system' as _source_system,
    current_timestamp() as _loaded_at,
    'ACCOUNT' as _record_source,
    {{ generate_change_key([
        'account_name', 'portfolio_id', 'registration_type', 'status', 'model_id',
        'advisor_code', 'custodian_code', 'fee_schedule', 'is_discretionary',
        'total_market_value', 'as_of_date'
    ]) }} as change_key
from {{ source('performance_system', 'account') }}
