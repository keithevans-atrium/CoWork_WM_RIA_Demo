select
    fee_id,
    account_number,
    billing_period_start,
    billing_period_end,
    fee_type,
    billable_aum,
    fee_rate,
    fee_amount,
    debit_date,
    status,
    loaded_at
from {{ source('custodian', 'fee_billing') }}
