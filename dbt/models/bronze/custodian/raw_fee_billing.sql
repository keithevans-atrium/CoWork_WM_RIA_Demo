select
    {{ generate_pk(['fee_id']) }} as record_pk,
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
    loaded_at,
    'custodian' as _source_system,
    current_timestamp() as _loaded_at,
    'FEE_BILLING' as _record_source,
    {{ generate_change_key([
        'account_number', 'billing_period_start', 'billing_period_end', 'fee_type',
        'billable_aum', 'fee_rate', 'fee_amount', 'debit_date', 'status'
    ]) }} as change_key
from {{ source('custodian', 'fee_billing') }}
