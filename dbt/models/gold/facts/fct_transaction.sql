select
    t.transaction_id,
    t.account_number,
    t.trade_date,
    t.settle_date,
    t.transaction_type,
    t.cusip,
    t.ticker,
    t.security_description,
    t.quantity,
    t.price,
    t.gross_amount,
    t.net_amount,
    t.commission,
    t.fees,
    t.commission + t.fees as total_cost,
    t.cancel_status,
    ca.custodian_code,
    ca.rep_code
from {{ ref('raw_transaction') }} t
left join {{ ref('raw_custodial_account') }} ca
    on ca.account_number = t.account_number
