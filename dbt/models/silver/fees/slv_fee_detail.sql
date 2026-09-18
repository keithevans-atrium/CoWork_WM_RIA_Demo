select
    fb.fee_id,
    fb.account_number,
    fb.billing_period_start,
    fb.billing_period_end,
    fb.fee_type,
    fb.billable_aum,
    fb.fee_rate,
    fb.fee_amount,
    fb.debit_date,
    fb.status as fee_status,
    ca.custodian_code,
    ca.rep_code,
    fa.account_id as sfdc_account_id,
    fa.custodian_name
from {{ ref('brz_fee_billing') }} fb
left join {{ ref('brz_custodial_account') }} ca
    on ca.account_number = fb.account_number
left join {{ ref('brz_financial_account') }} fa
    on fa.financial_account_number = fb.account_number
