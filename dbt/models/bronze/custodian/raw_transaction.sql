select
    {{ generate_pk(['transaction_id']) }} as record_pk,
    transaction_id,
    account_number,
    trade_date,
    settle_date,
    transaction_type,
    cusip,
    ticker,
    security_description,
    quantity,
    price,
    gross_amount,
    net_amount,
    commission,
    fees,
    cancel_status,
    loaded_at,
    'custodian' as _source_system,
    current_timestamp() as _loaded_at,
    'TRANSACTION' as _record_source,
    {{ generate_change_key([
        'account_number', 'trade_date', 'settle_date', 'transaction_type', 'cusip', 'ticker',
        'security_description', 'quantity', 'price', 'gross_amount', 'net_amount',
        'commission', 'fees', 'cancel_status'
    ]) }} as change_key
from {{ source('custodian', 'transaction') }}
