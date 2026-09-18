select
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
    loaded_at
from {{ source('custodian', 'transaction') }}
