select
    f.fee_id,
    f.account_number,
    f.billing_period_start,
    f.billing_period_end,
    f.fee_type,
    f.billable_aum,
    f.fee_rate,
    f.fee_amount,
    f.debit_date,
    f.fee_status,
    f.custodian_code,
    f.rep_code,
    f.sfdc_account_id,
    f.custodian_name,
    round(f.fee_amount * 4, 2) as annualized_fee
from {{ ref('fee_detail') }} f
